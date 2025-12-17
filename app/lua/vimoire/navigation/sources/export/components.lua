local M = {}
local cc = require("neo-tree.sources.common.components")
local vimoire_state = require("vimoire.state")
local view_config = require("vimoire.view.config")

local function get_view_attrs(node)
  local cfg = view_config[node.type]
  return cfg or {}
end

M.icon = function(config, node, state)
  local padding = config.padding or " "
  local item = vimoire_state.items[node.id]

  if item and item.icon then
    return {
      text = item.icon .. padding,
      highlight = item.highlight,
    }
  end

  -- Fall back to view config for items not in state (e.g. action nodes)
  local attrs = get_view_attrs(node)
  if attrs.icon then
    return {
      text = attrs.icon .. padding,
      highlight = attrs.highlight,
    }
  end

  return cc.icon(config, node, state)
end

M.name = function(config, node, state)
  local item = vimoire_state.items[node.id]
  if item then
    return {
      text = node.name,
      highlight = item.highlight,
    }
  end

  -- Fall back to view config for items not in state (e.g. action nodes)
  local attrs = get_view_attrs(node)
  local name = node.name
  if node.type == "action" then
    name = "[ " .. name .. " ]"
  end
  return {
    text = name,
    highlight = attrs.highlight or "NeoTreeFileName",
  }
end

return setmetatable(M, { __index = cc })
