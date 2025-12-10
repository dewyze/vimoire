local setup = {}
local state = require("vimoire.state")
local recent = require("vimoire.core.recent")

local function get_manuscript_path()
  local args = vim.fn.argv()

  if #args > 0 then
    local arg = args[1]
    if arg:match("manuscript%.json$") then
      return vim.fn.fnamemodify(arg, ":h")
    end
    return arg
  end

  return "."
end

local function on_manuscript_loaded()
  local neotree_source = require("vimoire.navigation.neotree_source")
  neotree_source.display_name = "󱓷 " .. state.manuscript.title
  recent.add(state.root, state.manuscript.title)
end

function setup.load_manuscript()
  local path = get_manuscript_path()
  state:load(path)

  if state.manuscript then
    on_manuscript_loaded()
    return true
  end

  vim.schedule(function()
    local start_screen = require("vimoire.ui.start_screen")
    start_screen.show()
  end)

  return false
end

function setup.show_start_screen()
  local start_screen = require("vimoire.ui.start_screen")
  start_screen.show()
end

return setup
