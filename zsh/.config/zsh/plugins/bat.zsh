if (( $+commands[bat] )); then
  local comp_file=~/.zsh/completions/_bat
  local version_file=~/.zsh/completions/.bat_version
  
  mkdir -p ~/.zsh/completions
  
  current_version=$(bat --version 2>/dev/null | head -1)
  cached_version=$(cat "$version_file" 2>/dev/null)
  
  if [[ ! -f "$comp_file" ]] || [[ "$current_version" != "$cached_version" ]]; then
    bat --completion zsh > "$comp_file" 2>/dev/null
    echo "$current_version" > "$version_file"
  fi
  
  fpath+=(~/.zsh/completions)
fi

# alias cat=bat
