#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_prereq() {
	echo "Checking packages..."
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		if [ "$(dpkg-query -W -f='${Status}' apt 2>/dev/null | grep -c "ok installed")" -eq 0 ]; then
			echo "Error - please install apt and run this script again."
			exit
		fi
		apt update
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		if ! which -s brew; then
			echo "Error - please install brew and run this script again."
			exit
		fi
		brew update
	else
		echo "Error - this script only works on linux or macos."
		exit
	fi
}

install_stow() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		sudo apt-get install -y build-essential gcc stow
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		brew install stow
	fi
}

install_mise() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		curl https://mise.run | sh
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		brew install mise
	fi
}

install_tools() {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		sudo apt install zsh
		# sudo apt install luajit luarocks neovim tree-sitter-cli tldr television wezterm
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		brew install luajit luarocks neovim tree-sitter-cli tldr television wezterm wget karabiner-elements
	fi
	[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] || zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
	git -C "$DOTFILES_DIR" submodule update --init --recursive
	stow -d "$DOTFILES_DIR" mise -t ~
	stow -d "$DOTFILES_DIR" wezterm -t ~
	stow -d "$DOTFILES_DIR" colorscheme -t ~
	stow -d "$DOTFILES_DIR" nvim -t ~
	stow -d "$DOTFILES_DIR" karabiner -t ~
	stow -d "$DOTFILES_DIR" codex -t ~
	stow -d "$DOTFILES_DIR" agents -t ~
	stow -d "$DOTFILES_DIR" pi-agent -t ~
  rm -rf ~/.zshrc
	stow -d "$DOTFILES_DIR" zsh -t ~
  rm -rf ~/.config/television
	stow -d "$DOTFILES_DIR" television -t ~
	mise install --jobs=1
}

echo "Setting up environment... 🚀"

check_prereq
install_stow
install_mise
install_tools

echo "Done. 👍"
