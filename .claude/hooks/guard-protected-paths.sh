#!/bin/bash
# Changing a settled, protected file needs the user's OK — once per file per piece of work.
#
#   PreToolUse  (Edit|Write|MultiEdit|Bash), no argument:
#     editing an existing protected file, or a shell command that writes one, raises a
#     permission prompt carrying Claude's reason (the newest REASON_MARKER line Claude wrote
#     in chat since the user's last message). Skipped for files with a live grant.
#   PostToolUse (same matcher), argument "post":
#     a write that actually ran was approved (or created a new file), so it grants that
#     file. A grant lives while the work goes on and lapses IDLE_MINUTES after the last
#     write to the file. Grants are per session; a new session starts with none.
#
# Claude cannot grant itself: a write that was refused never runs, so it never records.
# Rule source: design-system skill, "Never change existing component code unless explicitly told to".

# --- Project settings: swap these for another project ---
PROTECTED='DesignSystem/Sources/DesignSystem/(Components|Helpers)/'
LABEL='an existing design-system component'
REASON_MARKER='Component change:'
IDLE_MINUTES=45
# ---

mode=${1:-pre}
input=$(cat)
session=$(jq -r '.session_id // "none"' <<<"$input")
grants="${TMPDIR:-/tmp}/claude-protected-grants/$session"

# A grant key is the path from the protected root on, so absolute (Edit) and relative
# (shell) spellings of the same file match.
key() { sed -E "s#.*(${PROTECTED})#\\1#" <<<"$1"; }

# Shell commands that write: in-place edits, redirects, moves, copies, deletes, git
# rewrites, and scripting interpreters (a script can write anything it names).
writes() {
  grep -Eq "(sed|perl)[^|;]* -i|>{1,2}[[:space:]]*[^[:space:]]*$PROTECTED|(^|[[:space:];&|(])(mv|rm|cp|tee|python3?|perl|ruby|node|swift)([[:space:]]|$)|git[[:space:]]+(mv|rm|checkout|restore)[[:space:]]" <<<"$1"
}

# Protected paths a command names.
paths_in() { grep -oE "[^[:space:]'\"=]*${PROTECTED}[^[:space:]'\";|)&]*" <<<"$1" | sort -u; }

targets=()
case $(jq -r '.tool_name' <<<"$input") in
  Edit|Write|MultiEdit)
    path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
    [[ "$path" =~ $PROTECTED ]] || exit 0
    # Before the write, a new file is free; after it, it exists either way.
    [[ "$mode" == pre && ! -e "$path" ]] && exit 0
    targets=("$path") ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    grep -Eq "$PROTECTED" <<<"$cmd" || exit 0
    writes "$cmd" || exit 0
    while IFS= read -r p; do [[ -n "$p" ]] && targets+=("$p"); done < <(paths_in "$cmd") ;;
  *) exit 0 ;;
esac
[[ ${#targets[@]} -gt 0 ]] || exit 0

if [[ "$mode" == post ]]; then
  mkdir -p "${grants%/*}"
  now=$(date +%s)
  for t in "${targets[@]}"; do printf '%s\t%s\n' "$now" "$(key "$t")" >> "$grants"; done
  exit 0
fi

# --- pre: every target needs a live grant, or the user is asked ---
cutoff=$(( $(date +%s) - IDLE_MINUTES * 60 ))
ungranted=()
for t in "${targets[@]}"; do
  k=$(key "$t")
  [[ -f "$grants" ]] && awk -F'\t' -v k="$k" -v c="$cutoff" '$2 == k && $1 >= c { found = 1 } END { exit !found }' "$grants" \
    && continue
  ungranted+=("${k##*/}")
done
[[ ${#ungranted[@]} -eq 0 ]] && exit 0

# Claude's reason: the newest marker line in its chat text since the user last wrote.
reason=""
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
if [[ -f "$transcript" ]]; then
  reason=$(tail -n 400 "$transcript" | jq -rs '
      (map(.type == "user" and ((.message.content | type) == "string"
           or any(.message.content[]?; .type == "text"))) | indices(true) | last // -1) as $u
      | .[($u + 1):][] | select(.type == "assistant")
      | .message.content[]? | select(.type == "text") | .text' 2>/dev/null \
    | grep -F "$REASON_MARKER" | tail -n 1 | sed "s/.*$REASON_MARKER[[:space:]]*//" | cut -c1-300)
fi
[[ -n "$reason" ]] || reason="none given in chat — deny, and ask Claude why the change is needed."

files=$(IFS=,; sed 's/,/, /g' <<<"${ungranted[*]}")
jq -n --arg r "Changes $LABEL ($files). Claude's reason: $reason — A yes also covers further edits to this file until $IDLE_MINUTES min pass without one." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
exit 0
