local M = {}
local cc = require("neo-tree.sources.common.components")

local function hex_to_icon(hex)
  return vim.fn.nr2char(tonumber(hex, 16))
end

local ICONS = {
  manuscript = hex_to_icon("0xf15d6"),
  chapter = hex_to_icon("0xf0bc2"),
  section = hex_to_icon("0xe6ad"),
  characters = hex_to_icon("0xf2b9"),
  settings = hex_to_icon("0xf0984"),
  reference = hex_to_icon("0xe678"),
  planning = hex_to_icon("0xf07c"),
  character = hex_to_icon("0xf4ca"),
  setting = hex_to_icon("0xf015"),
  reference_file = hex_to_icon("0xf15c"),
}

local HIGHLIGHTS = {
  manuscript = "VimoireManuscript",
  section = "VimoireSection",
  chapter = "VimoireChapter",
  planning = "VimoirePlanning",
  characters = "VimoirePlanningSubfolder",
  character = "VimoirePlanningItem",
  settings = "VimoirePlanningSubfolder",
  setting = "VimoirePlanningItem",
  reference = "VimoirePlanningSubfolder",
  reference_file = "VimoirePlanningItem",
}

M.icon = function(config, node, state)
  local padding = config.padding or " "
  local icon_char = ICONS[node.type]
  local highlight = HIGHLIGHTS[node.type]

  if icon_char then
    return {
      text = icon_char .. padding,
      highlight = highlight or "NeoTreeFileIcon",
    }
  end

  -- Fall back to common component for unknown types
  return cc.icon(config, node, state)
end

M.name = function(config, node, state)
  local highlight = HIGHLIGHTS[node.type] or "NeoTreeFileName"

  return {
    text = node.name,
    highlight = highlight,
  }
end

return setmetatable(M, { __index = cc })
