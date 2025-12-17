local cc = require("neo-tree.sources.common.commands")
local vimoire_state = require("vimoire.state")
local delete_options = require("vimoire.core.delete_options")

local M = {}

-- Explicit assignments for neo-tree validation
M.open_split = cc.open_split
M.open_vsplit = cc.open_vsplit
M.toggle_node = cc.toggle_node
M.close_node = cc.close_node
M.close_all_nodes = cc.close_all_nodes
M.expand_all_nodes = cc.expand_all_nodes
M.close_window = cc.close_window
M.show_help = cc.show_help

function M.refresh(state, focus_id)
  vimoire_state:rebuild()
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name, function()
    if focus_id then
      local renderer = require("neo-tree.ui.renderer")
      renderer.focus_node(state, focus_id)
    end
  end)
end

function M.open(state)
  local node = state.tree:get_node()
  if node.extra and node.extra.action and node.extra.action() then
    return
  end
  cc.toggle_node(state)
end

function M.delete(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local result = delete_options.for_item(item)
  if not result then return end

  if result.confirm then
    local choice = vim.fn.confirm("Delete " .. item:display_name() .. "?", "&Yes\n&No", 2)
    if choice == 1 and result.confirm.execute(item, vimoire_state) then
      M.refresh(state)
    end
  end
end

return M
