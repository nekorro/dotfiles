#!/bin/bash

_install_languages() {
	mise use -g rust@1.94
	mise use -g python@3.14
	mise use -g go@1.26
}

_install_tools() {
	mise use -g fzf@latest
	mise use -g ripgrep@latest
	mise use -g fd@latest
	mise use -g eza@latest
	mise use -g stylua@latest
	mise use -g zoxide@latest
	mise use -g bat@latest
	mise use -g neovim@stable
	mise use -g luajit@latest
	cargo install tealdeer
}

brew update
brew install mise
_install_languages
_install_tools
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
