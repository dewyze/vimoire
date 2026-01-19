local M = {}
local cc = require("neo-tree.sources.common.components")
local vimoire_state = require("vimoire.state")
local view = require("vimoire.view")

M.icon = function(config, node, state)
  local padding = config.padding or " "
  local item = vimoire_state.items[node.id]

  if item then
    local icon = view.icon_for(item.kind)
    local highlight = view.highlight_for(item.kind)
    if icon then
      return {
        text = icon .. padding,
        highlight = highlight,
      }
    end
  end

  -- Fall back to view lookup by node.type for items not in state (e.g. action nodes)
  local icon = view.icon_for(node.type)
  local highlight = view.highlight_for(node.type)
  if icon then
    return {
      text = icon .. padding,
      highlight = highlight,
    }
  end

  return cc.icon(config, node, state)
end

M.name = function(config, node, state)
  local item = vimoire_state.items[node.id]
  if item then
    return {
      text = node.name,
      highlight = view.highlight_for(item.kind),
    }
  end

  -- Fall back to view lookup by node.type for items not in state (e.g. action nodes)
  local highlight = view.highlight_for(node.type)
  local name = node.name
  if node.type == "action" then
    name = "[ " .. name .. " ]"
  end
  return {
    text = name,
    highlight = highlight or "NeoTreeFileName",
  }
end

return setmetatable(M, { __index = cc })
