local Page = {}
Page.__index = Page

local Path = require("plenary.path")
local Entry = require("vimoire.core.entry")

function Page.new(data, root)
  local self = setmetatable({}, Page)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.root = root
  self.kind = "page"
  return self
end

function Page.create(state, name, parent_items)
  local existing_ids = Entry.collect_ids(state.manuscript.items)
  local new_id = Entry.generate_id(existing_ids)

  -- Create entry directory and text.md
  local entry_dir = Path:new(state.manuscript.root, "entries", new_id)
  entry_dir:mkdir({ parents = true })
  local text_file = Path:new(entry_dir:absolute(), "text.md")
  text_file:write("", "w")

  local data = { id = new_id, kind = "page", name = name }
  table.insert(parent_items, data)

  state:save()
  return state.items[new_id]
end

function Page:text_path()
  return self.root .. "/entries/" .. self.id .. "/text.md"
end

function Page:notes_path()
  return self.root .. "/entries/" .. self.id .. "/notes.md"
end

function Page:display_number()
  return nil
end

function Page:update(state, attrs)
  local index = Entry.find_index(self.parent_items, self.id)
  if not index then return self end

  for k, v in pairs(attrs) do
    self[k] = v
    self.parent_items[index][k] = v
  end

  state:save()
  return state.items[self.id]
end

function Page:destroy(state)
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

return Page
