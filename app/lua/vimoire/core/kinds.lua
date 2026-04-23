local add_options = require("vimoire.core.add_options")

return {
  chapter = {
    base = "entries",
    text_filename = "prose.md",
    extras = true,
    numbered = true,
    toggle_to = "page",
    category = "prose",
    add_options = { add_options.CHAPTER, add_options.PAGE, add_options.SECTION },
    export_context = function(item)
      return { title = item.name, num = item.chapter_index }
    end,
  },

  page = {
    base = "entries",
    text_filename = "prose.md",
    extras = true,
    toggle_to = "chapter",
    category = "prose",
    add_options = { add_options.CHAPTER, add_options.PAGE, add_options.SECTION },
    export_context = function(item)
      return { title = item.name, actions = {} }
    end,
  },

  planning_item = {
    base = "planning",
    text_filename = "text.md",
    extras = false,
    category = "planning",
    add_options = { add_options.PLANNING_ITEM },
  },

  section = {
    container = true,
    category = "prose",
    add_options = { add_options.CHAPTER, add_options.PAGE, add_options.SECTION },
  },

  subfolder = {
    container = true,
    category = "planning",
    add_options = { add_options.PLANNING_ITEM },
  },
}
