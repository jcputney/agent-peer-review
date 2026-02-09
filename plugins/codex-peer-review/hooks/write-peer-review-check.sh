#!/bin/bash
# PreToolUse hook for Write: Check if writing significant implementation files

# Get the file path from environment or stdin
FILE_PATH="${CLAUDE_TOOL_INPUT:-}"
if [ -z "$FILE_PATH" ]; then
  INPUT=$(cat)
  if command -v jq &>/dev/null; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty' 2>/dev/null)
  else
    FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)
  fi
fi

# Check if writing implementation files (not config, not docs, not tests)
if [ -n "$FILE_PATH" ] && \
   echo "$FILE_PATH" | grep -qiE "\.(ts|js|py|go|rs|java|cpp|c|rb|swift|kt)$" && \
   ! echo "$FILE_PATH" | grep -qiE "(test|spec|\.config|\.d\.ts)"; then
  cat << 'EOF'
**Peer Review Check:** You're about to write implementation code.

If this is part of a larger implementation plan that hasn't been peer reviewed, consider:
1. Pausing to dispatch to `codex-peer-review:codex-peer-reviewer` with your design
2. Then proceeding with implementation after validation

Skip this if: trivial change, bug fix, or design was already peer reviewed.
EOF
fi
