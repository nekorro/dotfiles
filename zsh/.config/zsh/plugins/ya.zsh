export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/YandexInternalCA.pem
export ARCADIA_ROOT=/Users/nekorro/arcadia

# The next line updates PATH for Yandex Cloud CLI.
if [ -f '/Users/nekorro/yandex-cloud/path.bash.inc' ]; then source '/Users/nekorro/yandex-cloud/path.bash.inc'; fi

# The next line enables shell command completion for yc.
if [ -f '/Users/nekorro/yandex-cloud/completion.zsh.inc' ]; then source '/Users/nekorro/yandex-cloud/completion.zsh.inc'; fi

export PATH="$HOME/.local/bin:$PATH"
export DISABLE_TELEMETRY=1
export DISABLE_ERROR_REPORTING=1
export DISABLE_BUG_COMMAND=1

# The next line updates PATH for Yandex Cloud Private CLI.
if [ -f '/Users/nekorro/ycp/path.bash.inc' ]; then source '/Users/nekorro/ycp/path.bash.inc'; fi

alias t="ya tool"
alias sky="ya tool sky"
