local M = {}
local cc = require("neo-tree.sources.common.components")
local vimoire_state = require("vimoire.state")

M.icon = function(config, node, state)
  local padding = config.padding or " "
  local item = vimoire_state.items[node.id]

  if item and item.icon then
    return {
      text = item.icon .. padding,
      highlight = item.highlight,
    }
  end

  return cc.icon(config, node, state)
end

M.name = function(config, node, state)
  local item = vimoire_state.items[node.id]
  local highlight = item and item.highlight or "NeoTreeFileName"

  return {
    text = node.name,
    highlight = highlight,
  }
end

return setmetatable(M, { __index = cc })
