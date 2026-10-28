#!/bin/bash
# PreToolUse (Edit|Write|Bash): changing a settled, protected file needs the user's OK.
# Escalates to a permission prompt instead of denying — the user's "yes" is the approval.
# The prompt carries Claude's reason: the line starting with REASON_MARKER that Claude
# wrote in chat since the user's last message. New files pass; only existing ones are guarded.
# Rule source: design-system skill, "Never change existing component code unless explicitly told to".

# --- Project settings: swap these for another project ---
PROTECTED='DesignSystem/Sources/DesignSystem/(Components|Helpers)/'
LABEL='an existing design-system component'
REASON_MARKER='Component change:'
# ---

input=$(cat)
case $(jq -r '.tool_name' <<<"$input") in
  Edit|Write|MultiEdit)
    path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
    [[ "$path" =~ $PROTECTED ]] || exit 0
    [[ -e "$path" ]] || exit 0   # creating a new file is fine
    target=${path##*/} ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    grep -Eq "$PROTECTED" <<<"$cmd" || exit 0
    # Only commands that write: in-place edits, redirects into the path, moves, deletes.
    grep -Eq "(sed|perl)[^|;]* -i|>{1,2}[[:space:]]*[^[:space:]]*$PROTECTED|(^|[[:space:];&|])(mv|rm|cp|tee)[[:space:]]|git[[:space:]]+(mv|rm|checkout|restore)[[:space:]]" <<<"$cmd" || exit 0
    target='a shell command' ;;
  *) exit 0 ;;
esac

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

jq -n --arg r "Changes $LABEL ($target). Claude's reason: $reason" '{hookSpecificOutput: {
  hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
exit 0
