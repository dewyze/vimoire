local state = {
  manuscript = nil,
  entries = {},
  sections = {},
}

local Manuscript = require("vimoire.core.manuscript")
local Entry = require("vimoire.core.entry")

function state:load(manuscript_path)
  self.manuscript = Manuscript.load(manuscript_path)
  self:rebuild()
end

function state:save()
  self.manuscript:save()
  self:rebuild()
end

function state:rebuild()
  self.entries = {}
  self.sections = {}

  if not self.manuscript then
    return
  end

  local chapter_count = 0

  local function process_items(items, parent_section)
    for _, item_data in ipairs(items) do
      local item = Entry.build(item_data, self.manuscript.root)
      item.parent_items = items
      item.parent_section = parent_section

      if item.kind == "section" then
        self.sections[item.id] = item
        process_items(item_data.items or {}, item)
      else
        self.entries[item.id] = item
        if item.kind == "chapter" then
          chapter_count = chapter_count + 1
          item.chapter_index = chapter_count
        end
      end
    end
  end

  process_items(self.manuscript.items or {}, nil)
end

return state
