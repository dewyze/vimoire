local setup = {}
local state = require("vimoire.state")
local log = require("vimoire.util.log")

local function get_manuscript_path()
  local args = vim.fn.argv()

  if #args > 0 then
    local arg = args[1]
    -- If passed manuscript.json, use its parent directory
    if arg:match("manuscript%.json$") then
      return vim.fn.fnamemodify(arg, ":h")
    end
    -- Otherwise treat as directory
    return arg
  end

  -- Default to current directory
  return "."
end

function setup.load_manuscript()
  local path = get_manuscript_path()
  state:load(path)

  if not state.manuscript then
    log.error("Failed to load manuscript from " .. path)
    vim.schedule(function()
      vim.cmd("quit")
    end)
    return false
  end

  log.info("Loaded manuscript: " .. state.manuscript.title)
  return true
end

return setup
