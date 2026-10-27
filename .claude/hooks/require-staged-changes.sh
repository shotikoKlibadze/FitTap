#!/bin/bash
# Stop: don't end a turn with unstaged or untracked work in the repo.
# Rule source: CLAUDE.md §6 "Stage, don't commit" — stage with git add after every change.
input=$(cat)
# Already blocked once this turn → let it stop, so a deliberate leftover can't loop forever.
[[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" == "true" ]] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

unstaged=$( { git diff --name-only; git ls-files --others --exclude-standard; } | sort -u )
[[ -z "$unstaged" ]] && exit 0

jq -n --arg files "$unstaged" '{
  decision: "block",
  reason: ("Unstaged changes remain (project rule: stage, don'"'"'t commit). Stage the files you changed with git add, or say why one should stay unstaged:\n" + $files)
}'
exit 0
