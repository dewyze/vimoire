local Section = {}
Section.__index = Section

local Entry = require("vimoire.core.entry")

function Section.new(data, root)
  local self = setmetatable({}, Section)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.root = root
  self.kind = "section"
  self.items = self.items or {}
  return self
end

function Section.create(state, name, parent_items)
  local existing_ids = Entry.collect_ids(state.manuscript.items)
  local new_id = Entry.generate_id(existing_ids)

  -- Sections have no files
  local data = { id = new_id, kind = "section", name = name, items = {} }
  table.insert(parent_items, data)

  state:save()
  return state.items[new_id]
end

function Section:text_path()
  return nil
end

function Section:notes_path()
  return nil
end

function Section:display_number()
  return nil
end

function Section:display_name()
  return self.name
end

function Section:update(state, attrs)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return self end

  for k, v in pairs(attrs) do
    if k ~= "items" then -- Don't overwrite items via update
      self[k] = v
      self.parent_items[index][k] = v
    end
  end

  state:save()
  return state.items[self.id]
end

function Section:destroy(state)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return false end

  local children = self.parent_items[index].items or {}

  -- Remove section
  table.remove(self.parent_items, index)

  -- Insert children where section was
  for i, child in ipairs(children) do
    table.insert(self.parent_items, index + i - 1, child)
  end

  state:save()
  return true
end

return Section
