-- Reference: https://github.com/wez/wezterm/discussions/4796

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local isWindows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local isMac = wezterm.target_triple == "x86_64-apple-darwin"

local cmd
if isWindows then
    -- Windows:
    cmd = {
        "C:\\msys64\\usr\\bin\\find",
        -- Windows search paths:
        "c:\\Projetos",
        "c:\\Users\\Thiago\\AppData\\Local\\nvim",
        "c:\\Users\\Thiago\\.config",
        "c:\\msys64\\home\\Thiago\\.vim\\pack\\downloads\\opt",
        "c:\\msys64\\home\\Thiago\\.vim\\pack\\downloads\\start",
        --
        "-maxdepth",
        "3",
        "-mindepth",
        "1",
        "-type",
        "d",
        "-name",
        ".git",
    }
elseif isMac then
    -- macOS:
    cmd = {
        "find",
        -- macOS search paths:
        "/Users/thiago.negri/projects",
        "/Users/thiago.negri/.config",
        "/Users/thiago.negri/.vim/pack/downloads/opt",
        "/Users/thiago.negri/.vim/pack/downloads/start",
        --
        "-maxdepth",
        "2",
        "-mindepth",
        "0",
        "-type",
        "d",
        "-name",
        ".git",
    }
else
    -- Linux:
    cmd = {
        "find",
        -- Linux search paths:
        "/home/tnegri/projects",
        --
        "-maxdepth",
        "2",
        "-mindepth",
        "2",
        "-type",
        "d",
        "-name",
        ".git",
    }
end

wezterm.on("update-right-status", function(window)
    window:set_right_status(window:active_workspace())
end)

M.toggle = function(window, pane)
    local projects = {}

    local success, stdout, stderr = wezterm.run_child_process(cmd)

    if not success then
        wezterm.log_error("Failed to run fd: " .. stderr)
        return
    end

    for line in stdout:gmatch("([^\n]*)\n?") do
        local project = line:gsub("[\\/].git[\\/]?$", "")
        local label = project
        local id = label:gsub(".*[\\/]", "")
        table.insert(projects, { label = tostring(id), id = tostring(label) })
    end

    window:perform_action(
        act.InputSelector({
            action = wezterm.action_callback(function(win, _, id, label)
                if not id and not label then
                    wezterm.log_info("Cancelled")
                else
                    wezterm.log_info("Selected " .. label)
                    win:perform_action(act.SwitchToWorkspace({ name = label, spawn = { cwd = id } }), pane)
                end
            end),
            fuzzy = true,
            title = "Select project",
            choices = projects,
        }),
        pane
    )
end

return M
