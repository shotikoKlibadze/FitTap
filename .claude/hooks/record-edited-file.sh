#!/bin/bash
# PostToolUse Edit|Write: remember which files the agent touched this session,
# so the Stop check only nags about the agent's own work, not the user's.
input=$(cat)
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$session" || -z "$file" ]] && exit 0
dir="${TMPDIR:-/tmp}/claude-edited-files"
mkdir -p "$dir" && printf '%s\n' "$file" >> "$dir/$session"
exit 0
