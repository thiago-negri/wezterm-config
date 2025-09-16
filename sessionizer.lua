-- Reference: https://github.com/wez/wezterm/discussions/4796

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local isWindows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local isMac = wezterm.target_triple == "x86_64-apple-darwin"

local cmd_git
local cmd_fossil
if isWindows then
    -- Windows:
    cmd_git = {
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
    cmd_fossil = nil
elseif isMac then
    -- macOS:
    cmd_git = {
        "find",
        -- macOS search paths:
        "/Users/thiago.negri/projects/bc",
        "/Users/thiago.negri/projects/ehg",
        "/Users/thiago.negri/projects/tnegri",
        "/Users/thiago.negri/projects/other",
        "/Users/thiago.negri/.config",
        "/Users/thiago.negri/.gg",
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
    cmd_fossil = nil
else
    -- Linux:
    cmd_git = {
        "find",
        -- Linux search paths:
        "/home/hunz/.gg",
        "/home/hunz/projects",
        "/home/hunz/.config",
        --
        "-maxdepth",
        "2",
        "-mindepth",
        "1",
        "-type",
        "d",
        "-name",
        ".git",
    }
    cmd_fossil = {
        "find",
        -- Linux search paths:
        "/home/hunz/projects",
        "/home/hunz/.config",
        --
        "-maxdepth",
        "3",
        "-mindepth",
        "2",
        "-type",
        "f",
        "-name",
        ".fslckout",
    }
end

wezterm.on("update-right-status", function(window)
    window:set_right_status(window:active_workspace())
end)

M.toggle = function(window, pane)
    local projects = {}

    -- Git repositories
    local success, stdout, stderr = wezterm.run_child_process(cmd_git)

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

    -- Fossil repositories
    if cmd_fossil ~= nil then
        success, stdout, stderr = wezterm.run_child_process(cmd_fossil)

        if not success then
            wezterm.log_error("Failed to run fd: " .. stderr)
            return
        end

        for line in stdout:gmatch("([^\n]*)\n?") do
            local project = line:gsub("[\\/].fslckout[\\/]?$", "")
            local label = project
            local id = label:gsub("^.*[\\/]([^\\/]+[\\/])", "%1")
            table.insert(projects, { label = tostring(id), id = tostring(label) })
        end
    end

    table.sort(projects, function(a, b)
        return a.label < b.label
    end)

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
