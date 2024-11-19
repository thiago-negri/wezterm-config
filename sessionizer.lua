-- Reference: https://github.com/wez/wezterm/discussions/4796

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local isWindows = wezterm.target_triple == "x86_64-pc-windows-msvc"

-- Windows:
local fd = "c:\\Users\\Thiago\\AppData\\Local\\Microsoft\\WinGet\\Links\\fd"
local cmd = {
  fd,
  "-HI",
  "-td",
  "^.git$",
  "--max-depth=4",
  -- Windows search paths:
  "c:\\Projetos\\",
  "c:\\Users\\Thiago\\AppData\\Local\\nvim\\",
  "c:\\Users\\Thiago\\.config\\",
}

-- macOS:
if not isWindows then
end

wezterm.on('update-right-status', function(window, pane)
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
    local project = line:gsub("[\\/].git[\\/]$", "")
    local label = project
    local id = project:gsub(".*[\\/]", "")
    table.insert(projects, { label = tostring(label), id = tostring(id) })
  end

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(win, _, id, label)
        if not id and not label then
          wezterm.log_info("Cancelled")
        else
          wezterm.log_info("Selected " .. label)
          win:perform_action(
            act.SwitchToWorkspace({ name = id, spawn = { cwd = label } }),
            pane
          )
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
