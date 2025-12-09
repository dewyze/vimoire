local Section = {}
Section.__index = Section

local Entry = require("vimoire.core.entry")

function Section.new(data, root, opts)
  opts = opts or {}
  local self = setmetatable({}, Section)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.root = root
  self.kind = "section"
  self.items = self.items or {}
  self.immutable = opts.immutable or false
  self.icon = opts.icon
  self.highlight = opts.highlight
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

function Section:promote_children(state)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return end

  local children = self.parent_items[index].items or {}

  -- Insert children after this section
  for i, child in ipairs(children) do
    table.insert(self.parent_items, index + i, child)
  end

  -- Clear our items
  self.parent_items[index].items = {}
  self.items = {}

  state:save()
end

function Section:destroy_children(state)
  for i = #self.items, 1, -1 do
    local child = state.items[self.items[i].id]
    child:destroy_children(state)
    child:destroy(state)
  end
end

function Section:destroy(state)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return false end

  table.remove(self.parent_items, index)

  state:save()
  return true
end

return Section
