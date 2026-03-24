# zmodload zsh/zprof


[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

mkdir -p ~/.zsh/completions

plug "zap-zsh/supercharge"
plug "$HOME/.config/zsh/plugins/zoxide.zsh"
plug "$HOME/.config/zsh/plugins/mcc.zsh"
plug "$HOME/.config/zsh/plugins/mise.zsh"
# # plug "$HOME/.config/zsh/plugins/vim.zsh"
plug "$HOME/.config/wezterm/wezterm.sh"
plug "$HOME/.config/zsh/plugins/eza.zsh"
plug "$HOME/.config/zsh/plugins/ripgrep.zsh"
plug "$HOME/.config/zsh/plugins/bat.zsh"
plug "$HOME/.config/zsh/plugins/television.zsh"
plug "zap-zsh/fzf"

# Load and initialise completion system
autoload -Uz compinit
compinit

plug "Aloxaf/fzf-tab"
# plug "Freed-Wu/fzf-tab-source"

plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

plug "zettlrobert/simple-prompt"

# zprof
