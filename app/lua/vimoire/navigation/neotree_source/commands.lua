local M = {}
local cc = require("neo-tree.sources.common.commands")
local vimoire_state = require("vimoire.state")
local movement = require("vimoire.core.movement")
local delete_options = require("vimoire.core.delete_options")

-- Custom: refresh tree
M.refresh = function(state, focus_id)
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name, function()
    if focus_id then
      local renderer = require("neo-tree.ui.renderer")
      renderer.focus_node(state, focus_id)
    end
  end)
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
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local options = delete_options.options_for(item)
  if not options then return end

  local labels = delete_options.labels(options, item)

  vim.ui.select(labels, {
    prompt = "Delete " .. item:display_name() .. "?",
  }, function(choice)
    local opt = delete_options.find_by_label(options, choice, item)
    if opt and opt.execute(item, vimoire_state) then
      M.refresh(state)
    end
  end)
end

-- Custom: move to different section
M.move = function(state)
  -- TODO: implement
  vim.notify("Move not yet implemented", vim.log.levels.INFO)
end

local function get_id(node)
  return node.id
end

-- Custom: reorder up (K)
M.move_up = function(state)
  local id = get_id(state.tree:get_node())
  if id and movement.move_up(vimoire_state, id) then
    M.refresh(state, id)
  end
end

-- Custom: reorder down (J)
M.move_down = function(state)
  local id = get_id(state.tree:get_node())
  if id and movement.move_down(vimoire_state, id) then
    M.refresh(state, id)
  end
end

return M
