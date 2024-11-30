local wezterm = require("wezterm")
local sessionizer = require("sessionizer")

local mux = wezterm.mux
local config = wezterm.config_builder()
local act = wezterm.action
local isWindows = wezterm.target_triple == "x86_64-pc-windows-msvc"

if isWindows then
    -- Windows specific config
    -- cmd -> MSYS2 -> Fish
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
    -- If you want to use Git Bash
    -- config.default_prog = {
    --     "C:\\Windows\\System32\\cmd.exe",
    --     "/c",
    --     "C:\\Program Files\\Git\\bin\\sh.exe",
    -- }
else
    -- Use Fish shell for MacOS and Linux
    config.default_prog = { "/usr/local/bin/fish" }
end

-- Show workspace name at left bottom
wezterm.on("update-right-status", function(window)
    window:set_right_status(window:active_workspace())
end)

config.max_fps = 200;

-- Hide window manager title bar with resize/close buttons
config.window_decorations = "RESIZE"
-- Maximize on start
wezterm.on("gui-startup", function(cmd)
    local _, _, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- Matching color scheme and font of NVIM
-- config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("CommitMono Nerd Font")

-- My Windows monitor is way bigger :)
if isWindows then
   config.font_size = 14
else
   config.font_size = 18
end

-- Kanagawa
config.force_reverse_video_cursor = true
config.colors = {
    foreground = "#dcd7ba",
    background = "#1f1f28",

    cursor_bg = "#c8c093",
    cursor_fg = "#c8c093",
    cursor_border = "#c8c093",

    selection_fg = "#c8c093",
    selection_bg = "#2d4f67",

    scrollbar_thumb = "#16161d",
    split = "#16161d",

    ansi = { "#090618", "#c34043", "#76946a", "#c0a36e",
        "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
    brights = { "#727169", "#e82424", "#98bb6c", "#e6c384",
        "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
    indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}

-- Use standard tab bar at bottom
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Leader is C-b
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

local leader = "LEADER"

-- Keybindings
config.keys = {
    -- Sessionizer / Workspaces
    { key = "f", mods = leader, action = wezterm.action_callback(sessionizer.toggle) },
    { key = "q", mods = leader, action = act.SwitchToWorkspace { name = 'default' } },
    { key = "w", mods = leader, action = wezterm.action_callback(function (win, pane) 
        win:perform_action(
            act.SwitchToWorkspace({ name = "projects", spawn = { cwd = "C:\\Projetos" } }),
            pane
        )
    end) },
    { key = "e", mods = leader, action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },

    -- Move between panes, HJKL
    { key = "h", mods = leader, action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = leader, action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = leader, action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = leader, action = act.ActivatePaneDirection("Right") },

    -- Resize panes, <>TS
    { key = "<", mods = leader, action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = ">", mods = leader, action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "T", mods = leader, action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "S", mods = leader, action = act.AdjustPaneSize({ "Down", 5 }) },

    -- Zoom in/out (change font size), -=
    { key = "=", mods = leader, action = act.IncreaseFontSize },
    { key = "-", mods = leader, action = act.DecreaseFontSize },

    -- Maximize a pane, M
    { key = "m", mods = leader, action = act.TogglePaneZoomState },

    -- Move between tabs, []
    { key = "[", mods = leader, action = act.ActivateTabRelative(-1) },
    { key = "]", mods = leader, action = act.ActivateTabRelative(1) },

    -- Go to tab, 1 .. 9
    { key = "1", mods = leader, action = act.ActivateTab(0) },
    { key = "2", mods = leader, action = act.ActivateTab(1) },
    { key = "3", mods = leader, action = act.ActivateTab(2) },
    { key = "4", mods = leader, action = act.ActivateTab(3) },
    { key = "5", mods = leader, action = act.ActivateTab(4) },
    { key = "6", mods = leader, action = act.ActivateTab(5) },
    { key = "7", mods = leader, action = act.ActivateTab(6) },
    { key = "8", mods = leader, action = act.ActivateTab(7) },
    { key = "9", mods = leader, action = act.ActivateTab(8) },

    -- New tab, N
    { key = "n", mods = leader, action = act.SpawnTab("CurrentPaneDomain") },

    -- Split tab, VS
    { key = "v", mods = leader, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "s", mods = leader, action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Close pane, Q
    { key = "q", mods = leader, action = act.CloseCurrentPane({ confirm = false }) },

    -- Enter VI mode, '
    { key = "'", mods = leader, action = act.ActivateCopyMode },

    -- Rename tab, R
    {
        key = "r",
        mods = leader,
        action = act.PromptInputLine({
            description = "Enter new name for tab",
            action = wezterm.action_callback(function(window, _, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
    },
}

return config
