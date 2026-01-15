#!/bin/bash
# SessionStart hook to remind Claude about peer review requirements
# This hook runs at the start of each Claude Code session

# Check if codex CLI is available
CODEX_STATUS=""
if command -v codex &>/dev/null; then
  CODEX_STATUS="✓ Codex CLI is installed"
else
  CODEX_STATUS="⚠ Codex CLI not found. Install with: npm i -g @openai/codex"
fi

cat << EOF
## Peer Review Requirement

**BEFORE presenting any of the following to the user, you MUST dispatch to the \`codex-peer-reviewer\` agent:**
- Implementation plans or designs
- Code review results
- Architecture recommendations
- Major refactoring proposals
- Answers to broad technical questions

**How to trigger:** Use the Task tool to dispatch to the \`codex-peer-reviewer\` agent with your findings. The agent runs in a **separate context** to keep the main conversation clean, then returns only the synthesized peer review result.

Example:
\`\`\`
Task tool with subagent_type="codex-peer-review:codex-peer-reviewer"
prompt: "Validate this design: [your design summary]"
\`\`\`

**Why:** Two AI perspectives catch more issues than one. Running as a subagent keeps Codex CLI output isolated and returns only distilled results.

**Codex CLI Status:** $CODEX_STATUS
EOF
