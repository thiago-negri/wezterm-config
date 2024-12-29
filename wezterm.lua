local wezterm = require("wezterm")
local sessionizer = require("sessionizer")

local mux = wezterm.mux
local config = wezterm.config_builder()
local act = wezterm.action
local isWindows = wezterm.target_triple == "x86_64-pc-windows-msvc"

-- Use ZSH
if isWindows then
    -- Windows specific config
    -- cmd -> MSYS2 -> ZSH
    config.default_prog = {
        "C:\\Windows\\System32\\cmd.exe",
        "/c",
        "C:\\msys64\\msys2_shell.cmd",
        "-defterm",
        "-here",
        "-no-start",
        "-mingw64",
        "-shell",
        -- "fish",
        "zsh",
    }
else
    -- config.default_prog = { "/usr/local/bin/fish" }
    config.default_prog = { "zsh" }
end

-- Show workspace name at left bottom
wezterm.on("update-right-status", function(window)
    window:set_right_status(window:active_workspace())
end)

config.max_fps = 200
config.tab_max_width = 4
config.show_tab_index_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- Hide window manager title bar with resize/close buttons
config.window_decorations = "RESIZE"
-- Maximize on start
wezterm.on("gui-startup", function(cmd)
    local _, _, window = mux.spawn_window(cmd or {})
    if isWindows then
        window:gui_window():set_position(500, 10)
    else
        window:gui_window():maximize()
    end
end)
config.initial_cols = 125
config.initial_rows = 57

config.font = wezterm.font("Comic Code")

-- My Windows monitor is way bigger :)
if isWindows then
   config.font_size = 14
else
   config.font_size = 18
end

-- Colorscheme
config.colors = {
    foreground = "#bcbcbc",
    background = "#000000",
    cursor_bg = "#bcbcbc",
    cursor_fg = "#000000",
    cursor_border = "#bcbcbc",
    selection_fg = "#000000",
    selection_bg = "#5f5f5f",
    scrollbar_thumb = "#333333",
    split = "#333333",
    ansi = {
        '#444444', -- black
        '#B39393', -- red
        '#93B393', -- green
        '#B3B393', -- yellow
        '#9393B3', -- blue
        '#B393B3', -- magenta
        '#93B3B3', -- cyan
        '#B3B3B3', -- white
    },
    brights = {
        '#555555', -- black
        '#C39393', -- red
        '#93C393', -- green
        '#C3C393', -- yellow
        '#9393C3', -- blue
        '#C393C3', -- magenta
        '#93C3C3', -- cyan
        '#C3C3C3', -- white
    },
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
    { key = "t", mods = leader, action = act.SplitPane({ direction = "Down", size = { Cells = 10 } }) },

    -- Close pane, Q
    { key = "q", mods = leader, action = act.CloseCurrentPane({ confirm = false }) },

    -- Enter VI mode, '
    { key = "'", mods = leader, action = act.ActivateCopyMode },

    -- Toggle window decoration, m
    { key = "m", mods = leader, action = act.EmitEvent "toggle-window-decoration" },

    -- Toggle font, ;
    { key = ";", mods = leader, action = act.EmitEvent "toggle-window-font" },

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

wezterm.on('toggle-window-maximize', function(window, pane)
    window:toggle_fullscreen()
end)

wezterm.on('toggle-window-font', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.font then
        overrides.font = wezterm.font("CommitMono Nerd Font")
    else
        overrides.font = nil
    end
    window:set_config_overrides(overrides)
end)

wezterm.on('toggle-window-decoration', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.window_decorations then
        overrides.window_decorations = "TITLE | RESIZE"
    else
        overrides.window_decorations = nil
    end
    window:set_config_overrides(overrides)
end)

return config

