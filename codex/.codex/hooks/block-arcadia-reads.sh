#!/bin/bash
# Block access to arcadia except some folders
# Handles: Read (file_path), Grep (path), Glob (path), Bash (command)

INPUT=$(cat)

# Only apply in ~/arcadia directory
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
if [[ "$CWD" != "$HOME/arcadia"* ]]; then
  exit 0
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

BLOCKED_DIRS=(
  "$HOME/arcadia"
)

ALLOWED_SUBDIRS=(
  "$HOME/arcadia/yandex360"
  "$HOME/arcadia/ai"
  "$HOME/arcadia/collab"
  "$HOME/arcadia/contrib"
  "$HOME/arcadia/disk"
  "$HOME/arcadia/mail"
)

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

check_path() {
  local check_path="$1"
  [ -z "$check_path" ] && return 0

  for blocked in "${BLOCKED_DIRS[@]}"; do
    if [[ "$check_path" == "$blocked"/* || "$check_path" == "$blocked" ]]; then
      for allowed_dir in "${ALLOWED_SUBDIRS[@]}"; do
        if [[ "$check_path" == "$allowed_dir"/* || "$check_path" == "$allowed_dir" ]]; then
          return 0
        fi
      done
      deny "Blocked: access to $blocked is not allowed"
    fi
  done
  return 0
}

case "$TOOL_NAME" in
  Read)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    check_path "$FILE_PATH"
    ;;
  Grep|Glob)
    DIR_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
    check_path "$DIR_PATH"
    ;;
  Bash)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    for blocked in "${BLOCKED_DIRS[@]}"; do
      if [[ "$COMMAND" == *"$blocked"* ]]; then
        # Check if the command only references allowed subdirs
        has_blocked=false
        # Remove all allowed subdir occurrences and check if blocked dir still present
        cleaned="$COMMAND"
        for allowed_dir in "${ALLOWED_SUBDIRS[@]}"; do
          cleaned="${cleaned//$allowed_dir/}"
        done
        if [[ "$cleaned" == *"$blocked"* ]]; then
          deny "Blocked: command references $blocked"
        fi
      fi
    done
    ;;
esac

exit 0
