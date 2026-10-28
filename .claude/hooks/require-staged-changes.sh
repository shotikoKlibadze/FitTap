#!/bin/bash
# Stop: don't end a turn with unstaged or untracked work the agent made.
# Rule source: CLAUDE.md §6 "Stage, don't commit" — stage with git add after every change.
# Scope: only files the agent edited this session (recorded by record-edited-file.sh),
# so the user's own in-progress edits are never flagged.
input=$(cat)
# Already blocked once this turn → let it stop, so a deliberate leftover can't loop forever.
[[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" == "true" ]] && exit 0

session=$(printf '%s' "$input" | jq -r '.session_id // empty')
log="${TMPDIR:-/tmp}/claude-edited-files/$session"
[[ -z "$session" || ! -s "$log" ]] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
root=$(git rev-parse --show-toplevel)

dirty=$( { git diff --name-only; git ls-files --others --exclude-standard; } | sort -u )
[[ -z "$dirty" ]] && exit 0

# Agent-edited files, as repo-relative paths (files outside the repo drop out).
edited=$(sort -u "$log" | while IFS= read -r f; do
  [[ "$f" == "$root"/* ]] && printf '%s\n' "${f#"$root"/}"
done | sort -u)

unstaged=$(comm -12 <(printf '%s\n' "$dirty") <(printf '%s\n' "$edited"))
[[ -z "$unstaged" ]] && exit 0

jq -n --arg files "$unstaged" '{
  decision: "block",
  reason: ("Unstaged changes remain (project rule: stage, don'"'"'t commit). Stage the files you changed with git add, or say why one should stay unstaged:\n" + $files)
}'
exit 0
