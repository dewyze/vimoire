local constants = require("vimoire.core.constants")
local add_options = require("vimoire.core.add_options")

return {
  -- Book metadata (immutable, opens book.yml)
  book = {
    icon = constants.ICONS.BOOK,
    highlight = constants.HIGHLIGHTS.BOOK,
    immutable = true,
  },

  -- Top-level folders (immutable)
  manuscript = {
    icon = constants.ICONS.MANUSCRIPT,
    highlight = constants.HIGHLIGHTS.MANUSCRIPT,
    add_options = { add_options.SECTION, add_options.CHAPTER, add_options.PAGE },
    immutable = true,
  },
  planning = {
    icon = constants.ICONS.PLANNING,
    highlight = constants.HIGHLIGHTS.PLANNING,
    immutable = true,
  },
  characters = {
    icon = constants.ICONS.CHARACTERS,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
    add_options = { add_options.PLANNING_ITEM },
    immutable = true,
  },
  settings = {
    icon = constants.ICONS.SETTINGS,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
    add_options = { add_options.PLANNING_ITEM },
    immutable = true,
  },
  reference = {
    icon = constants.ICONS.REFERENCE,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
    add_options = { add_options.PLANNING_ITEM, add_options.SUBFOLDER },
    immutable = true,
  },

  -- Manuscript entries
  section = {
    icon = constants.ICONS.SECTION,
    highlight = constants.HIGHLIGHTS.SECTION,
    add_options = { add_options.CHAPTER, add_options.PAGE },
  },
  chapter = {
    icon = constants.ICONS.CHAPTER,
    highlight = constants.HIGHLIGHTS.CHAPTER,
    add_options = { add_options.CHAPTER, add_options.PAGE },
  },
  page = {
    icon = constants.ICONS.PAGE,
    highlight = constants.HIGHLIGHTS.PAGE,
    add_options = { add_options.CHAPTER, add_options.PAGE },
  },

  -- Planning entries
  subfolder = {
    icon = constants.ICONS.PLANNING_SECTION,
    highlight = constants.HIGHLIGHTS.PLANNING_SUBFOLDER,
    add_options = { add_options.PLANNING_ITEM },
  },
  planning_item = {
    icon = constants.ICONS.PLANNING_ITEM,
    highlight = constants.HIGHLIGHTS.PLANNING_ITEM,
    add_options = { add_options.PLANNING_ITEM },
  },

  -- Export section
  export = {
    icon = constants.ICONS.EXPORT,
    highlight = constants.HIGHLIGHTS.EXPORT,
    immutable = true,
  },
  export_folder = {
    icon = constants.ICONS.EXPORT_FOLDER,
    highlight = constants.HIGHLIGHTS.EXPORT_FOLDER,
    immutable = true,
  },
  export_file = {
    icon = constants.ICONS.EXPORT_FILE,
    highlight = constants.HIGHLIGHTS.EXPORT_FILE,
  },
}
