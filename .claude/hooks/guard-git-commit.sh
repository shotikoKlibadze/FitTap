#!/bin/bash
# PreToolUse (Bash): never commit unless the user explicitly says so.
# Instead of a hard deny, escalate to a permission prompt — the user's "yes" IS the explicit approval.
# Rule source: CLAUDE.md §6 "Stage, don't commit".
cmd=$(jq -r '.tool_input.command // empty')
if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+commit([[:space:]]|$)'; then
  jq -n '{hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: "Project rule: stage, don'"'"'t commit. Approve only if you explicitly asked for this commit."
  }}'
fi
exit 0
