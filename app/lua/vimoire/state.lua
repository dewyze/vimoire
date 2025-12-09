local state = {
  manuscript = nil,
  items = {},
}

local Manuscript = require("vimoire.core.manuscript")
local Entry = require("vimoire.core.entry")
local Document = require("vimoire.core.document")
local Section = require("vimoire.core.section")
local add_options = require("vimoire.core.add_options")

local function icon(hex)
  return vim.fn.nr2char(tonumber(hex, 16))
end

local ICONS = {
  manuscript = icon("0xf15d6"),
  section = icon("0xe6ad"),
  chapter = icon("0xf0bc2"),
  page = icon("0xf249"),
  planning = icon("0xf07c"),
  characters = icon("0xf2b9"),
  settings = icon("0xf0984"),
  reference = icon("0xe678"),
  planning_section = icon("0xf07c"),
  planning_item = icon("0xf15c"),
}

function state:load(manuscript_path)
  self.manuscript = Manuscript.load(manuscript_path)
  self:rebuild()
end

function state:save()
  self.manuscript:save()
  self:rebuild()
end

function state:rebuild()
  self.items = {}

  if not self.manuscript then
    return
  end

  local root = self.manuscript.root
  local chapter_count = 0

  -- Add option sets
  local manuscript_add = { add_options.SECTION, add_options.CHAPTER, add_options.PAGE, add_options.CANCEL }
  local entry_add = { add_options.CHAPTER, add_options.PAGE, add_options.CANCEL }
  local planning_item_add = { add_options.PLANNING_ITEM, add_options.CANCEL }
  local reference_add = { add_options.PLANNING_ITEM, add_options.SUBFOLDER, add_options.CANCEL }

  -- Immutable sections (top-level containers)
  self.items["manuscript"] = Section.new({ id = "manuscript", name = "Manuscript", items = self.manuscript.items }, root, { immutable = true, icon = ICONS.manuscript, highlight = "VimoireManuscript", add_options = manuscript_add })
  self.items["planning"] = Section.new({ id = "planning", name = "Planning" }, root, { immutable = true, icon = ICONS.planning, highlight = "VimoirePlanning" })
  self.items["characters"] = Section.new({ id = "characters", name = "Characters", items = self.manuscript.characters }, root, { immutable = true, icon = ICONS.characters, highlight = "VimoirePlanningSubfolder", add_options = planning_item_add })
  self.items["settings"] = Section.new({ id = "settings", name = "Settings", items = self.manuscript.settings }, root, { immutable = true, icon = ICONS.settings, highlight = "VimoirePlanningSubfolder", add_options = planning_item_add })
  self.items["reference"] = Section.new({ id = "reference", name = "Reference", items = self.manuscript.reference }, root, { immutable = true, icon = ICONS.reference, highlight = "VimoirePlanningSubfolder", add_options = reference_add })

  -- Entries and sections
  local entry_opts = {
    section = { icon = ICONS.section, highlight = "VimoireSection", add_options = entry_add },
    chapter = { icon = ICONS.chapter, highlight = "VimoireChapter", add_options = entry_add },
    page = { icon = ICONS.page, highlight = "VimoirePage", add_options = entry_add },
  }

  local function process_items(items, parent_section)
    for _, item_data in ipairs(items) do
      local opts = entry_opts[item_data.kind] or entry_opts.chapter
      local item = Entry.build(item_data, root, opts)
      item.parent_items = items
      item.parent_section = parent_section
      self.items[item.id] = item

      if item_data.items then
        process_items(item_data.items, item)
      elseif item.kind == "chapter" then
        chapter_count = chapter_count + 1
        item.chapter_index = chapter_count
      end
    end
  end

  process_items(self.manuscript.items or {}, nil)

  -- Planning items and sections
  local planning_section_opts = { icon = ICONS.planning_section, highlight = "VimoirePlanningSubfolder", add_options = planning_item_add }
  local planning_item_opts = { base = "planning", extras = false, icon = ICONS.planning_item, highlight = "VimoirePlanningItem", add_options = planning_item_add }

  local function process_planning(items, parent_items)
    for _, data in ipairs(items or {}) do
      if data.items then
        local section = Section.new(data, root, planning_section_opts)
        section.parent_items = parent_items
        self.items[data.id] = section
        process_planning(data.items, data.items)
      else
        data.kind = data.kind or "planning_item"
        local item = Document.new(data, root, planning_item_opts)
        item.parent_items = parent_items
        self.items[data.id] = item
      end
    end
  end

  process_planning(self.manuscript.characters, self.manuscript.characters)
  process_planning(self.manuscript.settings, self.manuscript.settings)
  process_planning(self.manuscript.reference, self.manuscript.reference)
end

return state
