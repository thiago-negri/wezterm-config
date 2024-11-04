local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Use Git Bash on Windows
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = {
		"C:\\Windows\\System32\\cmd.exe",
		"/c",
		"C:\\msys64\\msys2_shell.cmd",
		"-defterm",
		"-here",
		"-no-start",
		"-mingw64",
		"-shell",
		"fish",
	}
	-- config.default_prog = {
	-- 	"C:\\Windows\\System32\\cmd.exe",
	-- 	"/c",
	-- 	"C:\\Program Files\\Git\\bin\\sh.exe",
	-- }
end

-- Matching color scheme and font of NVIM
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("CommitMono Nerd Font")
config.font_size = 18

-- Hide window manager title bar with resize/close buttons
config.window_decorations = "RESIZE"

-- Use standard tab bar at bottom
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Leader is C-b
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

-- Keybindings
config.keys = {
	-- Move between panes, HJKL
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Move between tabs, []
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },

	-- Go to tab, 1 .. 9
	{ key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },

	-- New tab
	{ key = "n", mods = "LEADER", action = wezterm.action.SpawnTab("DefaultDomain") },

	-- Split tab
	{ key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Close pane
	{ key = "q", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

	-- Rename tab
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Open wezterm config file
	{
		key = ",",
		mods = "LEADER",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = os.getenv("WEZTERM_CONFIG_DIR"),
			args = {
				"nvim",
				os.getenv("WEZTERM_CONFIG_FILE"),
			},
		}),
	},
}

return config
