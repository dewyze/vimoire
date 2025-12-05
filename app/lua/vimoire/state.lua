local state = {
  manuscript = nil,
  items = {},
}

local Manuscript = require("vimoire.core.manuscript")
local Entry = require("vimoire.core.entry")
local PlanningItem = require("vimoire.core.planning_item")
local Folder = require("vimoire.core.folder")

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

  -- Immutable folders
  self.items["manuscript"] = Folder.new("manuscript", "Manuscript")
  self.items["planning"] = Folder.new("planning", "Planning")
  self.items["characters"] = Folder.new("characters", "Characters")
  self.items["settings"] = Folder.new("settings", "Settings")
  self.items["reference"] = Folder.new("reference", "Reference")

  -- Entries and sections
  local function process_items(items, parent_section)
    for _, item_data in ipairs(items) do
      local item = Entry.build(item_data, root)
      item.parent_items = items
      item.parent_section = parent_section
      self.items[item.id] = item

      if item.kind == "section" then
        process_items(item_data.items or {}, item)
      elseif item.kind == "chapter" then
        chapter_count = chapter_count + 1
        item.chapter_index = chapter_count
      end
    end
  end

  process_items(self.manuscript.items or {}, nil)

  -- Planning items
  local function process_planning(items, planning_type)
    for _, data in ipairs(items or {}) do
      self.items[data.id] = PlanningItem.new(data, planning_type, root)
    end
  end

  process_planning(self.manuscript.characters, "characters")
  process_planning(self.manuscript.settings, "settings")
  process_planning(self.manuscript.reference, "reference")
end

return state
