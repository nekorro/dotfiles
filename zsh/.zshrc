# zmodload zsh/zprof


[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
export PATH=$PATH:~/bin

mkdir -p ~/.zsh/completions

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history

plug "$HOME/.config/zsh/plugins/mise.zsh"

plug "zap-zsh/supercharge"
plug "$HOME/.config/zsh/plugins/zoxide.zsh"
plug "$HOME/.config/zsh/plugins/mcc.zsh"
# # plug "$HOME/.config/zsh/plugins/vim.zsh"
plug "$HOME/.config/wezterm/wezterm.sh"
plug "$HOME/.config/zsh/plugins/eza.zsh"
plug "$HOME/.config/zsh/plugins/ripgrep.zsh"
plug "$HOME/.config/zsh/plugins/bat.zsh"
plug "$HOME/.config/zsh/plugins/television.zsh"
plug "$HOME/.config/zsh/plugins/ya.zsh"
plug "$HOME/.config/zsh/plugins/secrets.zsh"
plug "$HOME/.config/zsh/plugins/arcmnt/arcmnt.zsh"
plug "$HOME/.config/zsh/plugins/task/task.zsh"
plug "zap-zsh/fzf"

fpath+=(~/.zsh/completions)

# Load and initialise completion system
setopt nonomatch complete_aliases
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

# The next line updates PATH for Yandex Cloud CLI.
if [ -f '/Users/nekorro/yandex-cloud/path.bash.inc' ]; then source '/Users/nekorro/yandex-cloud/path.bash.inc'; fi

# The next line enables shell command completion for yc.
if [ -f '/Users/nekorro/yandex-cloud/completion.zsh.inc' ]; then source '/Users/nekorro/yandex-cloud/completion.zsh.inc'; fi

export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/YandexInternalCA.pem"
export PATH="$HOME/.local/bin:$PATH"
export DISABLE_TELEMETRY=1
export DISABLE_ERROR_REPORTING=1
export DISABLE_BUG_COMMAND=1
