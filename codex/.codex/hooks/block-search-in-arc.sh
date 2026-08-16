#!/bin/bash
# Block Grep/Glob tools when searching in ~/arcadia — recommend /code-search skill instead

INPUT=$(cat)

ARC_DIR="$HOME/arcadia"

# Only apply in ~/arcadia directory
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
if [[ "$CWD" != "$ARC_DIR"* ]]; then
  exit 0
fi

deny() {
  jq -n \
    --arg reason "$1" \
    '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
  exit 0
}

SEARCH_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // empty')

# If no explicit path, check cwd
if [ -z "$SEARCH_PATH" ]; then
  SEARCH_PATH=$(echo "$INPUT" | jq -r '.cwd // empty')
fi

[ -z "$SEARCH_PATH" ] && exit 0

if [[ "$SEARCH_PATH" == "$ARC_DIR"* ]]; then
  deny "Grep/Glob в ~/arcadia запрещены. Для поиска по коду используй скилл /code-search"
fi

exit 0
