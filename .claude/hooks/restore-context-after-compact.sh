#!/bin/bash
# SessionStart (matcher: compact): after the conversation is compacted, re-add the facts a
# summary tends to lose. Plain text on stdout + exit 0 → added to Claude's context.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

echo "## Context restored after compaction"
echo
echo "Key project rules (full text in CLAUDE.md and .claude/skills/):"
echo "- iOS 27+ only; no @available checks or fallbacks."
echo "- Stage, don't commit: git add after every change; commit only when the user says so."
echo "- Done = it compiles (one build); no tests unless asked."
echo "- Answer short."
echo "- Apple API facts come from Knowledge/ (iOSAI, iOSHealthKit, watchOS); one code file per WWDC video."
echo "- Feature plans live in Planning/."
echo

# Most recently modified staged files first, capped so a big uncommitted backlog
# doesn't flood the context.
staged=$(git diff --cached --name-only 2>/dev/null)
if [[ -n "$staged" ]]; then
  total=$(printf '%s\n' "$staged" | wc -l | tr -d ' ')
  echo "Recently changed staged files (newest first, $total staged in total):"
  printf '%s\n' "$staged" | while IFS= read -r f; do
    [[ -e "$f" ]] && printf '%s\t%s\n' "$(stat -f %m "$f")" "$f"
  done | sort -rn | head -15 | cut -f2 | sed 's/^/- /'
else
  echo "No staged changes yet."
fi
exit 0
