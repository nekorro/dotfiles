#!/bin/sh
set -eu

resolver="$HOME/.agents/skills/external-memory/scripts/resolve-vault.sh"
if [ ! -f "$resolver" ]; then
  printf 'external-memory vault resolver not found: %s\n' "$resolver" >&2
  exit 1
fi

vault="$(bash "$resolver")"
export SMART_VAULT_PATH="$vault"
exec npx -y smart-connections-mcp
