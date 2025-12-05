local Chapter = {}
Chapter.__index = Chapter

local Path = require("plenary.path")
local Entry = require("vimoire.core.entry")

function Chapter.new(data, root)
  local self = setmetatable({}, Chapter)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.root = root
  self.kind = "chapter"
  return self
end

function Chapter.create(state, name, parent_items)
  local existing_ids = Entry.collect_ids(state.manuscript.items)
  local new_id = Entry.generate_id(existing_ids)

  -- Create entry directory and text.md
  local entry_dir = Path:new(state.manuscript.root, "entries", new_id)
  entry_dir:mkdir({ parents = true })
  local text_file = Path:new(entry_dir:absolute(), "text.md")
  text_file:write("", "w")

  local data = { id = new_id, kind = "chapter", name = name }
  table.insert(parent_items, data)

  state:save()
  return state.items[new_id]
end

function Chapter:text_path()
  return self.root .. "/entries/" .. self.id .. "/text.md"
end

function Chapter:notes_path()
  return self.root .. "/entries/" .. self.id .. "/notes.md"
end

function Chapter:display_number()
  return self.chapter_index and tostring(self.chapter_index) or nil
end

function Chapter:display_name()
  local num = self:display_number()
  if num then
    return num .. ": " .. self.name
  end
  return self.name
end

function Chapter:update(state, attrs)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return self end

  for k, v in pairs(attrs) do
    self[k] = v
    self.parent_items[index][k] = v
  end

  state:save()
  return state.items[self.id]
end

function Chapter:destroy(state)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return false end

  -- Delete files
  local entry_dir = Path:new(self.root, "entries", self.id)
  if entry_dir:exists() then
    vim.fn.delete(entry_dir:absolute(), "rf")
  end

  table.remove(self.parent_items, index)
  state:save()
  return true
end

return Chapter
