local M = {}
local cc = require("neo-tree.sources.common.commands")
local vimoire_state = require("vimoire.state")
local Chapter = require("vimoire.core.chapter")
local Section = require("vimoire.core.section")
local PlanningItem = require("vimoire.core.planning_item")

-- Custom: refresh tree
M.refresh = function(state)
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name)
end

-- Custom: open file or toggle folder
M.open = function(state)
  local node = state.tree:get_node()
  if node.path then
    vim.cmd("edit " .. node.path)
  else
    cc.toggle_node(state)
  end
end

-- From common: navigation
M.open_split = cc.open_split
M.open_vsplit = cc.open_vsplit
M.toggle_node = cc.toggle_node
M.close_node = cc.close_node
M.close_all_nodes = cc.close_all_nodes
M.expand_all_nodes = cc.expand_all_nodes

-- From common: window
M.close_window = cc.close_window
M.show_help = cc.show_help

-- Custom: add (context-aware)
M.add = function(state)
  -- TODO: implement
  vim.notify("Add not yet implemented", vim.log.levels.INFO)
end

-- Custom: rename
M.rename = function(state)
  -- TODO: implement
  vim.notify("Rename not yet implemented", vim.log.levels.INFO)
end

-- Custom: delete
M.delete = function(state)
  -- TODO: implement
  vim.notify("Delete not yet implemented", vim.log.levels.INFO)
end

-- Custom: move to different section
M.move = function(state)
  -- TODO: implement
  vim.notify("Move not yet implemented", vim.log.levels.INFO)
end

-- Custom: reorder up
M.move_up = function(state)
  -- TODO: implement
  vim.notify("Move up not yet implemented", vim.log.levels.INFO)
end

-- Custom: reorder down
M.move_down = function(state)
  -- TODO: implement
  vim.notify("Move down not yet implemented", vim.log.levels.INFO)
end

return M
