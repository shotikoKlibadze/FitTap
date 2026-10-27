#!/bin/bash
# PostToolUse (Edit|Write): toolbars belong on the Screen, never in a *View.swift.
# Exit 2 sends stderr back to Claude so it fixes the file. Rule source: .claude/skills/architecture.
f=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
[[ "$f" == *View.swift && -f "$f" ]] || exit 0

bad=$(grep -nE '\.(appToolbar|toolbar)\(' "$f" | cut -d: -f1)

if [[ -n "$bad" ]]; then
  echo "Toolbar rule violated in $f: .appToolbar(/.toolbar( in a View at line(s): $(echo $bad | tr ' ' ',')." >&2
  echo "Move it to the matching *Screen.swift as .appToolbar(title:onBack:) (see the architecture skill)." >&2
  exit 2
fi
exit 0
