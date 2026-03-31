-- https://github.com/mikatpt/dotfiles/blob/main/src/.config/.wezterm.lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- config.term = "wezterm"
config.term = "xterm-256color"
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local is_wsl = false
if is_windows then
	is_wsl, _, _ = wezterm.run_child_process({ "where", "wsl.exe" })
end

config.default_prog = is_wsl and { "wsl.exe", "--distribution", "Ubuntu-24.04" } or nil
config.default_domain = is_wsl and "WSL:Ubuntu-24.04" or "local"
config.scrollback_lines = 10000
config.max_fps = 240
config.audible_bell = "Disabled"
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 1000 }

-- UI
config.font = wezterm.font("FiraCode Nerd Font")
config.freetype_load_flags = "NO_HINTING"
config.font_size = 14.0
config.cursor_blink_rate = 0
local theme_dir = os.getenv("HOME") .. "/.config/colorscheme/extras/wezterm"
config.color_scheme_dirs = { theme_dir }
config.color_scheme = "kanagawa-paper-ash"

local tabline_apply = require("tabline")
tabline_apply(config)

local kb = require("keybindings")

config.keys = kb.keys
config.key_tables = kb.key_tables

return config
