#!/bin/bash
# PreToolUse hook for Task: Check if dispatching to a review-related agent

# Get tool input from environment or stdin
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
if [ -z "$TOOL_INPUT" ]; then
  TOOL_INPUT=$(cat)
fi

# Check if this is dispatching to a code review or similar agent (but NOT our peer reviewer)
if echo "$TOOL_INPUT" | grep -qiE "code-review|review|architect|design" && \
   ! echo "$TOOL_INPUT" | grep -qiE "codex-peer-review"; then
  cat << 'EOF'
**Peer Review Reminder:** You're dispatching to a review/design agent.

After this agent returns, consider dispatching to `codex-peer-review:codex-peer-reviewer` to cross-validate the findings before presenting to the user.
EOF
fi
