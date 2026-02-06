#!/bin/bash
# PreToolUse hook for Task: Check if dispatching to a review-related agent

# Read hook context from stdin (JSON)
INPUT=$(cat)

# The full JSON input contains tool parameters; check for review-related dispatch
TOOL_INPUT="$INPUT"

# Check if this is dispatching to a code review or similar agent (but NOT our peer reviewer)
if echo "$TOOL_INPUT" | grep -qiE "code-review|review|architect|design" && \
   ! echo "$TOOL_INPUT" | grep -qiE "codex-peer-review"; then
  cat << 'EOF'
**Peer Review Reminder:** You're dispatching to a review/design agent.

After this agent returns, consider dispatching to `codex-peer-review:codex-peer-reviewer` to cross-validate the findings before presenting to the user.
EOF
fi
