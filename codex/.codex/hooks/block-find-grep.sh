#!/bin/bash
# Block find/grep commands in Bash — recommend /code-search skill instead

INPUT=$(cat)

# Only apply in ~/arcadia directory
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
if [[ "$CWD" != "$HOME/arcadia"* ]]; then
  exit 0
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

[ "$TOOL_NAME" != "Bash" ] && exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

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

# Whitelist: `| grep ...` и `| rg ...` используются как фильтр stdout — разрешено.
# Вырезаем такие сегменты перед проверкой.
STRIPPED=$(echo "$COMMAND" | sed -E 's/\|[[:space:]]*grep\b[^|;&]*//g; s/\|[[:space:]]*rg\b[^|;&]*//g')

# Блокируем find, если стоит в начале команды или подкоманды
if echo "$STRIPPED" | grep -qE '(^|[;&]\s*|\$\(\s*)\bfind\b'; then
  deny "find/grep/rg запрещены. Для поиска по коду используй скилл /code-search (фильтрация через | grep|rg разрешена)"
fi

# Блокируем rg в любом виде, кроме фильтра stdout (он уже вырезан выше)
if echo "$STRIPPED" | grep -qE '(^|[;&][[:space:]]*|\$\([[:space:]]*)\brg\b'; then
  deny "find/grep/rg запрещены. Для поиска по коду используй скилл /code-search (фильтрация через | grep|rg разрешена)"
fi

# Блокируем grep, кроме случаев когда он направлен на конкретный файл (аргумент с расширением .ext)
GREP_CMDS=$(echo "$STRIPPED" | grep -oE '(^|[;&][[:space:]]*|\$\([[:space:]]*)\bgrep\b[^|;&]*' || true)
if [ -n "$GREP_CMDS" ]; then
  # Если хотя бы одна grep-команда НЕ содержит аргумент с расширением файла — блокируем
  if echo "$GREP_CMDS" | grep -qvE '[[:space:]][^[:space:]|;&]*\.[a-zA-Z0-9]{1,10}([[:space:]]|$)'; then
    deny "find/grep/rg запрещены. Для поиска по коду используй скилл /code-search (фильтрация через | grep|rg разрешена)"
  fi
fi

exit 0
