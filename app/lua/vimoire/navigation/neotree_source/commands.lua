local M = {}
local cc = require("neo-tree.sources.common.commands")

M.refresh = function(state)
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name)
end

M.open = function(state)
  local node = state.tree:get_node()
  if node.path then
    vim.cmd("edit " .. node.path)
  else
    cc.toggle_node(state)
  end
end

cc._add_common_commands(M)

return M
