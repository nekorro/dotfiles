#!/usr/bin/env zsh
# Task management helpers for arc branches

TASK_FILE="${0:A:h}/tasks.json"

# Ensure tasks file exists
[[ -f "$TASK_FILE" ]] || echo '{}' > "$TASK_FILE"

task() {
  local cmd="$1"
  shift

  case "$cmd" in
    new)           _task_new "$@" ;;
    ls|"")         _task_ls ;;
    sw)            _task_sw "$@" ;;
    rm)            _task_rm "$@" ;;
    resolve-names) _task_resolve_names ;;
    *)
      echo "Usage: task <command> [args]"
      echo "  ls                          - interactive task picker (default)"
      echo "  new  <TASK_ID> <REL_PATH>   - create branch and add task"
      echo "  sw   <TASK_ID>              - switch to task branch and cd"
      echo "  rm   <TASK_ID>              - delete branch and remove from list"
      echo "  resolve-names               - resolve missing task names from tracker"
      ;;
  esac
}

_task_arcadia_root() {
  arc root 2>/dev/null || echo "${HOME}/arcadia"
}

_task_st_token() {
  local t="${ST_TOKEN:-}"
  if [[ -z "$t" && -f ~/.config/tokens/startrek ]]; then
    t=$(< ~/.config/tokens/startrek)
  fi
  echo "$t"
}

_task_fzf_list() {
  jq -r 'to_entries[] | "\(.key)\t\(if .value.name == "" or .value.name == null then "" else .value.name end)\t\(.value.path // .value)"' "$TASK_FILE" | column -t -s $'\t'
}

_task_ls() {
  if [[ ! -s "$TASK_FILE" ]] || [[ "$(cat "$TASK_FILE")" == "{}" ]]; then
    echo "No tasks"
    return
  fi

  local result
  result=$(_task_fzf_list |
    fzf --height=~10 --reverse --prompt="task: " \
        --header="enter:switch  o:browser  n:new  d:delete  e:edit" \
        --bind="o:execute-silent(open https://st.yandex-team.ru/{1})" \
        --bind="d:execute-silent(jq --arg id {1} 'del(.[\$id])' $TASK_FILE > /tmp/_task_d && mv /tmp/_task_d $TASK_FILE)+reload(jq -r 'to_entries[] | \"\(.key)\t\(if .value.name == \"\" or .value.name == null then \"\" else .value.name end)\t\(.value.path // .value)\"' $TASK_FILE | column -t -s \$'\t')" \
        --bind="e:execute(\${EDITOR:-vim} $TASK_FILE)+reload(jq -r 'to_entries[] | \"\(.key)\t\(if .value.name == \"\" or .value.name == null then \"\" else .value.name end)\t\(.value.path // .value)\"' $TASK_FILE | column -t -s \$'\t')" \
        --bind="n:become(echo __NEW__)")

  [[ -n "$result" ]] || return

  if [[ "$result" == "__NEW__" ]]; then
    local task_id rel_path
    printf "Task ID: " && read -r task_id
    printf "Rel path: " && read -r rel_path
    [[ -n "$task_id" && -n "$rel_path" ]] && _task_new "$task_id" "$rel_path"
    return
  fi

  local task_id="${result%% *}"
  _task_sw "$task_id"
}

_task_pick() {
  if [[ ! -s "$TASK_FILE" ]] || [[ "$(cat "$TASK_FILE")" == "{}" ]]; then
    echo "No tasks" >&2
    return 1
  fi
  local selection
  selection=$(_task_fzf_list |
    fzf --height=~10 --reverse --prompt="${1:-Select task: }")
  [[ -n "$selection" ]] || return 1
  echo "$selection" | awk '{print $1}'
}

_task_resolve_name() {
  local task_id="$1" st_token="$2"
  curl -sf -H "Authorization: OAuth $st_token" \
    "https://st-api.yandex-team.ru/v2/issues/$task_id" 2>/dev/null | jq -r '.summary // empty'
}

_task_new() {
  local task_id="$1"
  local rel_path="$2"

  if [[ -z "$task_id" || -z "$rel_path" ]]; then
    echo "Usage: task new <TASK_ID> <REL_PATH>"
    return 1
  fi

  local arc_root=$(_task_arcadia_root)
  local branch="$task_id"

  cd "$arc_root" || return 1

  echo "Switching to trunk..."
  arc checkout trunk || return 1

  echo "Pulling latest..."
  arc pull || return 1

  echo "Creating branch $branch..."
  arc checkout -b "$branch" || return 1

  # Resolve task name from StarTrek
  local task_name=""
  local st_token=$(_task_st_token)
  if [[ -n "$st_token" ]]; then
    task_name=$(_task_resolve_name "$task_id" "$st_token")
    if [[ -n "$task_name" ]]; then
      echo "Task: $task_name"
    else
      echo "Warning: could not resolve task name from tracker"
    fi
  else
    echo "Warning: no ST_TOKEN, skipping task name resolution"
  fi

  # Save task
  local tmp=$(mktemp)
  jq --arg id "$task_id" --arg path "$rel_path" --arg name "$task_name" \
    '.[$id] = {path: $path, name: $name}' "$TASK_FILE" > "$tmp" && mv "$tmp" "$TASK_FILE"

  local target="$arc_root/$rel_path"
  if [[ -d "$target" ]]; then
    cd "$target"
  else
    echo "Warning: $arc_root/$rel_path does not exist, staying in $arc_root"
  fi

  echo "Task $task_id ready on branch $branch"
}


_task_resolve_names() {
  local st_token=$(_task_st_token)
  if [[ -z "$st_token" ]]; then
    echo "No ST_TOKEN available"
    return 1
  fi

  local ids
  ids=($(jq -r 'to_entries[] | select(.value.name == "" or .value.name == null) | .key' "$TASK_FILE"))

  if [[ ${#ids[@]} -eq 0 ]]; then
    echo "All tasks already have names"
    return
  fi

  local task_name tmp
  for tid in "${ids[@]}"; do
    task_name=$(_task_resolve_name "$tid" "$st_token")
    if [[ -n "$task_name" ]]; then
      tmp=$(mktemp)
      jq --arg id "$tid" --arg name "$task_name" '.[$id].name = $name' "$TASK_FILE" > "$tmp" && mv "$tmp" "$TASK_FILE"
      echo "$tid: $task_name"
    else
      echo "$tid: could not resolve"
    fi
  done
}

_task_sw() {
  local task_id="$1"

  if [[ -z "$task_id" ]]; then
    task_id=$(_task_pick "Switch to task: ") || return
  fi

  local rel_path
  rel_path=$(jq -r --arg id "$task_id" '.[$id].path // .[$id] // empty' "$TASK_FILE")

  if [[ -z "$rel_path" ]]; then
    echo "Task $task_id not found"
    return 1
  fi

  local arc_root=$(_task_arcadia_root)
  local branch="$task_id"

  cd "$arc_root" || return 1
  arc checkout "$branch" || return 1

  local target="$arc_root/$rel_path"
  if [[ -d "$target" ]]; then
    cd "$target"
  else
    echo "Warning: $arc_root/$rel_path does not exist, staying in $arc_root"
  fi

  echo "Switched to $task_id ($rel_path)"
}

_task_rm() {
  local task_id="$1"

  if [[ -z "$task_id" ]]; then
    task_id=$(_task_pick "Remove task: ") || return
  fi

  local rel_path
  rel_path=$(jq -r --arg id "$task_id" '.[$id].path // .[$id] // empty' "$TASK_FILE")

  if [[ -z "$rel_path" ]]; then
    echo "Task $task_id not found"
    return 1
  fi

  local arc_root=$(_task_arcadia_root)
  local branch="$task_id"

  cd "$arc_root" || return 1

  # Switch away if on the branch being deleted
  local current
  current=$(arc branch --show-current 2>/dev/null)
  if [[ "$current" == "$branch" ]]; then
    arc checkout trunk || return 1
  fi

  echo "Deleting branch $branch..."
  arc branch -D "$branch" 2>/dev/null || echo "Warning: branch $branch not found locally"

  # Remove from tasks file
  local tmp=$(mktemp)
  jq --arg id "$task_id" 'del(.[$id])' "$TASK_FILE" > "$tmp" && mv "$tmp" "$TASK_FILE"

  echo "Task $task_id removed"
}
