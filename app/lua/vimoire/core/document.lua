local Document = {}
Document.__index = Document

local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

function Document.new(data, root, opts)
  opts = opts or {}
  local self = setmetatable({}, Document)
  self.id = data.id
  self.name = data.name
  self.kind = data.kind
  self.root = root
  self.base = opts.base or "entries"
  self.extras = opts.extras ~= false
  self.icon = opts.icon
  self.highlight = opts.highlight
  self._add_options = opts.add_options
  return self
end

function Document:text_path()
  return self.root .. "/" .. self.base .. "/" .. self.id .. "/text.md"
end

function Document:notes_path()
  if not self.extras then return nil end
  return self.root .. "/" .. self.base .. "/" .. self.id .. "/notes.md"
end

function Document:display_number()
  return self.chapter_index and tostring(self.chapter_index) or nil
end

function Document:display_name()
  local num = self:display_number()
  if num then
    return num .. ": " .. self.name
  end
  return self.name
end

function Document:add_options()
  return self._add_options
end

function Document:add_parent_items()
  return self.parent_items
end

function Document.create(state, name, parent_items, opts)
  opts = opts or {}
  local new_id = id_util.generate(state.items)

  local data = {
    id = new_id,
    name = name,
    kind = opts.kind or "page",
  }

  -- Create directory and text.md
  local base = opts.base or "entries"
  local doc_dir = Path:new(state.manuscript.root, base, new_id)
  doc_dir:mkdir({ parents = true })
  local text_file = Path:new(doc_dir:absolute(), "text.md")
  text_file:write("", "w")

  table.insert(parent_items, data)
  state:save()

  return state.items[new_id]
end

function Document:update(state, attrs)
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      for k, v in pairs(attrs) do
        self[k] = v
        self.parent_items[i][k] = v
      end
      break
    end
  end

  state:save()
  return state.items[self.id]
end

function Document:destroy_children(_state)
  -- Documents have no children
end

function Document:destroy(state)
  -- Find and remove from parent_items
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      table.remove(self.parent_items, i)
      break
    end
  end

  -- Delete directory
  local doc_dir = Path:new(self.root, self.base, self.id)
  if doc_dir:exists() then
    vim.fn.delete(doc_dir:absolute(), "rf")
  end

  state:save()
  return true
end

return Document
