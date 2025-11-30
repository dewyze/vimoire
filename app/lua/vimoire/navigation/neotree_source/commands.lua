local M = {}
local cc = require("neo-tree.sources.common.commands")

M.refresh = function(state)
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name)
end

cc._add_common_commands(M)

return M
