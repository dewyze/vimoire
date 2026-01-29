local constants = require("vimoire.core.constants")

local M = {}

-- Internal lookup table: kind -> {icon, highlight}
local view_properties = {
  book = {
    icon = constants.ICONS.BOOK,
    highlight = constants.HIGHLIGHTS.BOOK,
  },
  manuscript = {
    icon = constants.ICONS.MANUSCRIPT,
    highlight = constants.HIGHLIGHTS.MANUSCRIPT,
  },
  planning = {
    icon = constants.ICONS.PLANNING,
    highlight = constants.HIGHLIGHTS.PLANNING,
  },
  characters = {
    icon = constants.ICONS.CHARACTERS,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
  },
  settings = {
    icon = constants.ICONS.SETTINGS,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
  },
  reference = {
    icon = constants.ICONS.REFERENCE,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
  },
  orphaned_notes = {
    icon = constants.ICONS.PLANNING_SECTION,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
  },
  section = {
    icon = constants.ICONS.SECTION,
    highlight = constants.HIGHLIGHTS.SECTION,
  },
  chapter = {
    icon = constants.ICONS.CHAPTER,
    highlight = constants.HIGHLIGHTS.CHAPTER,
  },
  page = {
    icon = constants.ICONS.PAGE,
    highlight = constants.HIGHLIGHTS.PAGE,
  },
  subfolder = {
    icon = constants.ICONS.PLANNING_SECTION,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
  },
  planning_item = {
    icon = constants.ICONS.PLANNING_ITEM,
    highlight = constants.HIGHLIGHTS.PLANNING_ITEM,
  },
  export = {
    icon = constants.ICONS.EXPORT,
    highlight = constants.HIGHLIGHTS.EXPORT,
  },
  export_folder = {
    icon = constants.ICONS.EXPORT_FOLDER,
    highlight = constants.HIGHLIGHTS.EXPORT_FOLDER,
  },
  export_file = {
    icon = constants.ICONS.EXPORT_FILE,
    highlight = constants.HIGHLIGHTS.EXPORT_FILE,
  },
  action = {
    icon = constants.ICONS.ACTION,
    highlight = constants.HIGHLIGHTS.ACTION,
  },
  plotting = {
    icon = constants.ICONS.PLOTTING,
    highlight = constants.HIGHLIGHTS.PLOTTING,
  },
  plotting_board = {
    icon = constants.ICONS.PLOTTING_BOARD,
    highlight = constants.HIGHLIGHTS.PLOTTING_BOARD,
  },
}

function M.icon_for(kind)
  local props = view_properties[kind]
  return props and props.icon
end

function M.highlight_for(kind)
  local props = view_properties[kind]
  return props and props.highlight
end

return M
