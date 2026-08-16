local wezterm = require("wezterm")
local default_keys = wezterm.gui.default_key_tables()
local act = wezterm.action

-- Helpers
local function extend_keys(target, source)
	local map = {}
	for i = 1, #target do
		local item = target[i]
		map[item.key] = item
	end
	for i = 1, #source do
		local item = source[i]
		local key = item.key
		if map[key] ~= nil then
			table[i] = map[key]
		else
			table.insert(target, source[i])
		end
	end
	return target
end

local close_copy_mode = act.Multiple({
	act.EmitEvent("update-status"),
	act.CopyMode("ClearSelectionMode"),
	act.CopyMode("ClearPattern"),
	act.CopyMode("Close"),
})

local show_launcher = act.Multiple({
	act.PopKeyTable,
	act.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }),
})

local copy_to = act.Multiple({ act.CopyTo("Clipboard"), act.CopyMode("ClearSelectionMode") })

local function next_match(int)
	local m = act.CopyMode(int == -1 and "PriorMatch" or "NextMatch")
	return act.Multiple({ m, act.CopyMode("ClearSelectionMode") })
end

local search = act.Multiple({
	act.CopyMode("ClearPattern"),
	act.EmitEvent("update-status"),
	act.Search({ CaseSensitiveString = "" }),
})

local function complete_search(should_clear)
	return wezterm.action_callback(function(window, pane, _)
		if should_clear then
			window:perform_action(act.CopyMode("ClearPattern"), pane)
		end
		window:perform_action(act.CopyMode("AcceptPattern"), pane)
		window:perform_action(act.EmitEvent("update-status"), pane)

		-- For some reason this just does not work unless we retry a few times.
		-- Probably something to do with state management between Search/Copy mode.
		for _ = 1, 3, 1 do
			wezterm.sleep_ms(100)
			window:perform_action(act.CopyMode("ClearSelectionMode"), pane)
		end
	end)
end

-- Keys
local keys = {
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{
		key = "w",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "window_mode",
			one_shot = false,
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.ActivateCopyMode,
	},
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
	{
		key = '"',
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "'",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{ key = "Tab", mods = "SHIFT", action = act.ActivatePaneDirection("Next") },
	{ key = "Enter", mods = "OPT", action = act.SendString("\x1b\r") },
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\x1b[13;2u") },
}

-- Key Tables
local key_tables = {
	-- Window Mode (leader + w)
	window_mode = {
		-- Panes
		{ key = "LeftArrow", action = act.ActivatePaneDirection("Left") },
		{ key = "h", action = act.ActivatePaneDirection("Left") },
		{
			key = "LeftArrow",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Left", 2 }),
		},
		{
			key = "h",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Left", 2 }),
		},
		{ key = "RightArrow", action = act.ActivatePaneDirection("Right") },
		{ key = "l", action = act.ActivatePaneDirection("Right") },
		{
			key = "RightArrow",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Right", 2 }),
		},
		{
			key = "l",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Right", 2 }),
		},
		{ key = "UpArrow", action = act.ActivatePaneDirection("Up") },
		{ key = "k", action = act.ActivatePaneDirection("Up") },
		{
			key = "UpArrow",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Up", 2 }),
		},
		{
			key = "k",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Up", 2 }),
		},
		{ key = "DownArrow", action = act.ActivatePaneDirection("Down") },
		{ key = "j", action = act.ActivatePaneDirection("Down") },
		{
			key = "DownArrow",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Down", 2 }),
		},
		{
			key = "j",
			mods = "SHIFT",
			action = act.AdjustPaneSize({ "Down", 2 }),
		},
		{ key = '"', action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "'", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

		-- Tabs
		{
			key = "r",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, _, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{ key = "w", action = show_launcher },
		{ key = "x", action = act.CloseCurrentTab({ confirm = true }) },
		{
			key = "x",
			mods = "SHIFT",
			action = act.CloseCurrentTab({ confirm = false }),
		},
		{ key = "c", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
		{ key = "[", action = act.ActivateTabRelative(-1) },
		{ key = "]", action = act.ActivateTabRelative(1) },
		{ key = "Tab", mods = "SHIFT", action = act.ActivateTabRelative(-1) },
		{ key = "Tab", action = act.ActivateTabRelative(1) },
		{ key = "0", action = act.ActivateTab(9) },
	},
	copy_mode = extend_keys(default_keys.copy_mode, {
		{ key = "c", mods = "CTRL", action = close_copy_mode },
		{ key = "q", mods = "NONE", action = close_copy_mode },
		{ key = "Escape", mods = "NONE", action = close_copy_mode },
		{ key = "Space", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{ key = "y", mods = "NONE", action = copy_to },
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "/", mods = "NONE", action = search },
		{ key = "?", mods = "SHIFT", action = search },
		{ key = "p", mods = "CTRL", action = next_match(-1) },
		{ key = "n", mods = "CTRL", action = next_match(1) },
		{ key = "n", mods = "NONE", action = next_match(1) },
		{ key = "N", mods = "NONE", action = next_match(-1) },
	}),
	search_mode = extend_keys(default_keys.search_mode, {
		{ key = "Escape", mods = "NONE", action = complete_search(true) },
		{ key = "Enter", mods = "NONE", action = complete_search(false) },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
	}),
}

-- Tab keys
for i = 1, 9 do
	table.insert(key_tables.window_mode, {
		key = tostring(i),
		action = act.ActivateTab(i - 1),
	})
end

return {
	keys = keys,
	key_tables = key_tables,
}
