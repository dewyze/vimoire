local state = {
  manuscript = nil,
  items = {},
}

local Manuscript = require("vimoire.core.manuscript")
local Entry = require("vimoire.core.entry")
local PlanningItem = require("vimoire.core.planning_item")
local Section = require("vimoire.core.section")

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

  -- Immutable sections (top-level containers)
  self.items["manuscript"] = Section.new({ id = "manuscript", name = "Manuscript" }, root, { immutable = true, icon = ICONS.manuscript, highlight = "VimoireManuscript" })
  self.items["planning"] = Section.new({ id = "planning", name = "Planning" }, root, { immutable = true, icon = ICONS.planning, highlight = "VimoirePlanning" })
  self.items["characters"] = Section.new({ id = "characters", name = "Characters" }, root, { immutable = true, icon = ICONS.characters, highlight = "VimoirePlanningSubfolder" })
  self.items["settings"] = Section.new({ id = "settings", name = "Settings" }, root, { immutable = true, icon = ICONS.settings, highlight = "VimoirePlanningSubfolder" })
  self.items["reference"] = Section.new({ id = "reference", name = "Reference" }, root, { immutable = true, icon = ICONS.reference, highlight = "VimoirePlanningSubfolder" })

  -- Entries and sections
  local entry_opts = {
    section = { icon = ICONS.section, highlight = "VimoireSection" },
    chapter = { icon = ICONS.chapter, highlight = "VimoireChapter" },
    page = { icon = ICONS.page, highlight = "VimoirePage" },
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
  local planning_section_opts = { icon = ICONS.planning_section, highlight = "VimoirePlanningSubfolder" }
  local planning_item_opts = { icon = ICONS.planning_item, highlight = "VimoirePlanningItem" }

  local function process_planning(items, base_path, parent_items)
    for _, data in ipairs(items or {}) do
      if data.items then
        local section = Section.new(data, root, planning_section_opts)
        section.parent_items = parent_items
        self.items[data.id] = section
        process_planning(data.items, base_path, data.items)
      else
        local item = PlanningItem.new(data, base_path, planning_item_opts)
        item.parent_items = parent_items
        self.items[data.id] = item
      end
    end
  end

  local planning_base = root .. "/planning"
  process_planning(self.manuscript.characters, planning_base .. "/characters", self.manuscript.characters)
  process_planning(self.manuscript.settings, planning_base .. "/settings", self.manuscript.settings)
  process_planning(self.manuscript.reference, planning_base .. "/reference", self.manuscript.reference)
end

return state
