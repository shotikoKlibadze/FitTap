#!/bin/bash
# PostToolUse (Edit|Write): every #Preview must sit inside an `#if DEBUG … #endif` block.
# Exit 2 sends stderr back to Claude so it fixes the file. Rule source: .claude/skills/previews.
f=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
[[ "$f" == *.swift && -f "$f" ]] || exit 0

bad=$(awk '
  # Track #if nesting; a line is "in DEBUG" if any enclosing #if mentions DEBUG.
  /^[[:space:]]*#if[[:space:]]/   { depth++; dbg[depth] = ($0 ~ /DEBUG/); next }
  /^[[:space:]]*#endif/           { if (depth > 0) depth--; next }
  /^[[:space:]]*#Preview/ {
    inDebug = 0
    for (i = 1; i <= depth; i++) if (dbg[i]) inDebug = 1
    if (!inDebug) print NR
  }
' "$f")

if [[ -n "$bad" ]]; then
  echo "Preview rule violated in $f: #Preview outside '#if DEBUG … #endif' at line(s): $(echo $bad | tr ' ' ',')." >&2
  echo "Wrap every #Preview and preview-only helper in #if DEBUG (see the previews skill)." >&2
  exit 2
fi
exit 0
