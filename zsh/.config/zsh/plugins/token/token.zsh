#!/usr/bin/env zsh
# OAuth token management plugin

TOKEN_CONFIG="${0:A:h}/tokens.yaml"

# Helper: get token file path
_token_path() {
  local p
  p=$(yq -r ".${1}.path" "$TOKEN_CONFIG" 2>/dev/null)
  echo "${p/#\~/$HOME}"
}

# Helper: get array of env names for a token
_token_envs() {
  yq -r ".${1}.envs // [] | .[]" "$TOKEN_CONFIG" 2>/dev/null
}

# Helper: read token value from file
_token_read() {
  local p=$(_token_path "$1")
  [[ -f "$p" ]] && < "$p"
}

# Auto-export env tokens on load
_token_auto_export() {
  [[ -f "$TOKEN_CONFIG" ]] || return

  local exports
  exports=$(yq -r '
    to_entries[] |
    (.value.path | sub("^~"; env(HOME))) as $path |
    .value.envs[]? |
    "\(.) \($path)"
  ' "$TOKEN_CONFIG" 2>/dev/null) || return

  local env_name token_path val
  while IFS=' ' read -r env_name token_path; do
    [[ -n "$env_name" && -f "$token_path" ]] || continue
    val=$(<"$token_path")
    [[ -n "$val" ]] && export "$env_name"="$val"
  done <<< "$exports"
}

_token_auto_export

token() {
  local cmd="$1"
  shift

  case "$cmd" in
    list|ls)     _token_list ;;
    refresh)     _token_refresh "$@" ;;
    refresh-all) _token_refresh_all ;;
    get)         _token_get "$@" ;;
    config)      echo "$TOKEN_CONFIG" ;;
    *)
      echo "Usage: token <command> [args]"
      echo "  list                - list tokens and their status"
      echo "  refresh [NAME]      - refresh a token (fzf picker if no NAME)"
      echo "  refresh-all         - refresh all missing tokens"
      echo "  get <NAME>          - print token value"
      echo "  config              - print config file path"
      ;;
  esac
}

_token_list() {
  [[ -f "$TOKEN_CONFIG" ]] || { echo "No config: $TOKEN_CONFIG"; return 1; }

  local names
  names=($(yq -r 'keys[]' "$TOKEN_CONFIG" 2>/dev/null))

  if [[ ${#names[@]} -eq 0 ]]; then
    echo "No tokens configured"
    return
  fi

  printf "%-15s %-20s %s\n" "NAME" "DESCRIPTION" "STATUS"
  printf "%-15s %-20s %s\n" "----" "-----------" "------"

  local name description token_status

  for name in "${names[@]}"; do
    description=$(yq -r ".${name}.description" "$TOKEN_CONFIG")
    token_status="missing"
    if [[ -n "$(_token_read "$name")" ]]; then
      token_status="exists"
    fi
    printf "%-15s %-20s %s\n" "$name" "$description" "$token_status"
  done
}

_token_pick() {
  [[ -f "$TOKEN_CONFIG" ]] || { echo "No config: $TOKEN_CONFIG" >&2; return 1; }

  local name description token_status lines=()

  for name in $(yq -r 'keys[]' "$TOKEN_CONFIG" 2>/dev/null); do
    description=$(yq -r ".${name}.description" "$TOKEN_CONFIG")
    token_status="missing"
    if [[ -n "$(_token_read "$name")" ]]; then
      token_status="exists"
    fi
    lines+=("$(printf "%-15s %-20s %s" "$name" "$description" "$token_status")")
  done

  local selection
  selection=$(printf '%s\n' "${lines[@]}" | fzf --height=~10 --reverse --prompt="${1:-Select token: }") || return 1
  echo "$selection" | awk '{print $1}'
}

_token_do_refresh() {
  local name="$1"
  local oauth_url description new_token p e

  oauth_url=$(yq -r ".${name}.oauth_url" "$TOKEN_CONFIG")
  description=$(yq -r ".${name}.description" "$TOKEN_CONFIG")

  echo "Refreshing token: $name ($description)"
  echo "Opening browser for OAuth..."
  open "$oauth_url"

  echo -n "Paste token: "
  read -r new_token

  if [[ -z "$new_token" ]]; then
    echo "Skipped (empty input)"
    return
  fi

  # Save to file
  p=$(_token_path "$name")
  mkdir -p "$(dirname "$p")"
  echo -n "$new_token" > "$p"
  chmod 600 "$p"

  # Export to all env vars
  for e in $(_token_envs "$name"); do
    export "$e"="$new_token"
  done

  echo "Token '$name' saved"
}

_token_refresh() {
  [[ -f "$TOKEN_CONFIG" ]] || { echo "No config: $TOKEN_CONFIG"; return 1; }

  local target="$1"

  if [[ -z "$target" ]]; then
    target=$(_token_pick "Refresh token: ") || return
  fi

  local check
  check=$(yq -r ".${target} // \"\"" "$TOKEN_CONFIG")
  if [[ -z "$check" ]]; then
    echo "Token '$target' not found in config"
    return 1
  fi

  _token_do_refresh "$target"
}

_token_refresh_all() {
  [[ -f "$TOKEN_CONFIG" ]] || { echo "No config: $TOKEN_CONFIG"; return 1; }

  local name

  for name in $(yq -r 'keys[]' "$TOKEN_CONFIG" 2>/dev/null); do
    if [[ -n "$(_token_read "$name")" ]]; then
      continue
    fi
    _token_do_refresh "$name"
  done
}

_token_get() {
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "Usage: token get <NAME>"
    return 1
  fi

  [[ -f "$TOKEN_CONFIG" ]] || { echo "No config: $TOKEN_CONFIG"; return 1; }

  local val
  val=$(_token_read "$name")

  if [[ -n "$val" ]]; then
    echo "$val"
  else
    echo "Token '$name' not found (run: token refresh $name)" >&2
    return 1
  fi
}
