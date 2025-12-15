local state = {
  manuscript = nil,
  book = nil,
  items = {},
  paths = {},
}

local Manuscript = require("vimoire.core.manuscript")
local Book = require("vimoire.core.book")
local Entry = require("vimoire.core.entry")
local PlanningSection = require("vimoire.core.planning_section")
local PlanningItem = require("vimoire.core.planning_item")
local Folder = require("vimoire.core.folder")
local view_config = require("vimoire.view.config")

local function apply_view(item)
  local config = view_config[item.kind] or {}
  item.icon = config.icon
  item.highlight = config.highlight
  item.add_options = config.add_options
  item.immutable = config.immutable or false
end

function state:load(manuscript_path)
  self.manuscript = Manuscript.load(manuscript_path)
  self.book = Book.load(manuscript_path)
  self:rebuild()
end

function state:save()
  self.manuscript:save()
  self:rebuild()
end

local function register_path(state, item)
  local text_path = item:text_path()
  if text_path then
    state.paths[vim.fn.fnamemodify(text_path, ":p")] = item
  end
  local notes_path = item:notes_path()
  if notes_path then
    state.paths[vim.fn.fnamemodify(notes_path, ":p")] = item
  end
end

function state:rebuild()
  self.items = {}
  self.paths = {}

  if not self.manuscript then
    return
  end

  local root = self.manuscript.root
  local chapter_count = 0

  -- Book metadata node
  if self.book then
    self.items[self.book.id] = self.book
    apply_view(self.book)
  end

  -- Folders (synthetic UI containers)
  self.items["manuscript"] = Folder.new("manuscript", "Manuscript", "manuscript", self.manuscript.items)
  self.items["planning"] = Folder.new("planning", "Planning", "planning", {
    { id = "characters" },
    { id = "settings" },
    { id = "reference" },
  })
  self.items["characters"] = Folder.new("characters", "Characters", "characters", self.manuscript.characters or {})
  self.items["settings"] = Folder.new("settings", "Settings", "settings", self.manuscript.settings or {})
  self.items["reference"] = Folder.new("reference", "Reference", "reference", self.manuscript.reference or {})

  -- Apply view config to folders
  for _, id in ipairs({ "manuscript", "planning", "characters", "settings", "reference" }) do
    apply_view(self.items[id])
  end

  -- Process manuscript entries
  local function process_items(items, parent_section)
    for _, item_data in ipairs(items) do
      local item = Entry.build(item_data, root)
      item.parent_items = items
      item.parent_section = parent_section
      apply_view(item)
      self.items[item.id] = item
      register_path(self, item)

      if item.items then
        process_items(item.items, item)
      elseif item.kind == "chapter" then
        chapter_count = chapter_count + 1
        item.chapter_index = chapter_count
      end
    end
  end

  process_items(self.manuscript.items or {}, nil)

  -- Process planning items
  local function process_planning(items, parent_items)
    for _, data in ipairs(items or {}) do
      local item
      if data.items then
        item = PlanningSection.new(data, root)
      else
        item = PlanningItem.new(data, root)
      end
      item.parent_items = parent_items
      apply_view(item)
      self.items[data.id] = item
      register_path(self, item)

      if data.items then
        process_planning(data.items, data.items)
      end
    end
  end

  process_planning(self.manuscript.characters, self.manuscript.characters)
  process_planning(self.manuscript.settings, self.manuscript.settings)
  process_planning(self.manuscript.reference, self.manuscript.reference)
end

return state
