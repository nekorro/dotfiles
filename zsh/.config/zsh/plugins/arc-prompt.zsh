#!/bin/zsh
# Display current arc branch in zsh prompt

function _arc_branch_info() {
  local branch
  branch=$(arc br 2>/dev/null | sed -n 's/^\* //p')
  if [[ -n "$branch" ]]; then
    echo "%F{15}on%{$reset_color%} %F{3}${branch}%{$reset_color%}"
  fi
}

# Insert arc branch info into existing PROMPT before git info
PROMPT="${PROMPT/\$vcs_info_msg_0_/\$(_arc_branch_info) \$vcs_info_msg_0_}"
