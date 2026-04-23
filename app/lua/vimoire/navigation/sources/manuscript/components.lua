local M = {}
local cc = require("neo-tree.sources.common.components")
local vimoire_state = require("vimoire.state")
local view = require("vimoire.view")
local constants = require("vimoire.core.constants")

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

  return cc.icon(config, node, state)
end

M.name = function(config, node, state)
  local item = vimoire_state.items[node.id]
  local highlight = item and view.highlight_for(item.kind) or "NeoTreeFileName"

  local result = { { text = node.name, highlight = highlight } }

  if item and item:has_notes() then
    table.insert(result, { text = " " .. constants.ICONS.NOTES_MARKER, highlight = constants.HIGHLIGHTS.MARKER })
  end
  if item and item:has_comments() then
    table.insert(result, { text = " " .. constants.ICONS.COMMENTS_MARKER, highlight = constants.HIGHLIGHTS.MARKER })
  end

  return result
end

return setmetatable(M, { __index = cc })
