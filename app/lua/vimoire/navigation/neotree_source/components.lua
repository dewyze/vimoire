local M = {}
local cc = require("neo-tree.sources.common.components")

M.icon = function(config, node, state)
  local padding = config.padding or " "

  if node.icon then
    return {
      text = node.icon .. padding,
      highlight = node.highlight,
    }
  end

  return cc.icon(config, node, state)
end

M.name = function(config, node, state)
  return {
    text = node.name,
    highlight = node.highlight,
  }
end

return setmetatable(M, { __index = cc })
