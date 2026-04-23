local Path = require("plenary.path")

local kinds = require("vimoire.core.kinds")
local id_util = require("vimoire.util.id")
local items_util = require("vimoire.util.items")

local FILE_DISPLAY_SUFFIXES = {
  ["notes.md"] = " - Notes",
}

local Item = {}
Item.__index = Item

-- Construction ---------------------------------------------------------------

function Item.new(kind, data, root)
  local self = setmetatable({}, Item)

  if kinds[kind].container then
    for k, v in pairs(data) do
      self[k] = v
    end
    self.items = self.items or {}
  else
    self.id = data.id
    self.name = data.name
  end

  self.kind = kind
  self.root = root
  return self
end

function Item.create(kind, state, name, parent_items, at_index)
  local config = kinds[kind]
  local new_id = id_util.generate(state.items)

  if config.container then
    local data = { id = new_id, kind = kind, name = name, items = {} }
    table.insert(parent_items, at_index, data)
    state:save()
    return state.items[new_id]
  end

  local data = { id = new_id, name = name, kind = kind }
  local doc_dir = Path:new(state.manuscript.root, config.base, new_id)
  doc_dir:mkdir({ parents = true })
  local text_file = Path:new(doc_dir:absolute(), config.text_filename)
  local frontmatter = string.format("---\ntitle: %s\n# subtitle: \n# epigraph: \n---\n\n", name)
  text_file:write(frontmatter, "w")

  table.insert(parent_items, at_index, data)
  state:save()
  return state.items[new_id]
end

-- Introspection --------------------------------------------------------------

function Item:container()
  return kinds[self.kind].container == true
end

function Item:base()
  return kinds[self.kind].base
end

function Item:extras()
  return kinds[self.kind].extras == true
end

function Item:category()
  return kinds[self.kind].category
end

function Item:numbered()
  return kinds[self.kind].numbered == true
end

function Item:add_options()
  return kinds[self.kind].add_options
end

-- Paths ----------------------------------------------------------------------

function Item:dir_path()
  if self:container() then return nil end
  return self.root .. "/" .. self:base() .. "/" .. self.id
end

function Item:text_path()
  local filename = kinds[self.kind].text_filename
  if not filename then return nil end
  return self:dir_path() .. "/" .. filename
end

function Item:notes_path()
  if not self:extras() then return nil end
  return self:dir_path() .. "/notes.md"
end

-- Display --------------------------------------------------------------------

function Item:display_number()
  if self:container() then return nil end
  return self.chapter_index and tostring(self.chapter_index) or nil
end

function Item:display_name()
  if self:container() then return self.name end
  local num = self:display_number()
  if num then return num .. ": " .. self.name end
  return self.name
end

function Item:display_name_for_path(filepath)
  local filename = filepath:match("([^/]+)$")
  local suffix = FILE_DISPLAY_SUFFIXES[filename] or ""
  return self:display_name() .. suffix
end

-- Action ---------------------------------------------------------------------

function Item:action()
  return false
end

-- Add-point semantics --------------------------------------------------------

function Item:add_parent_items()
  if self:container() then return self.items end
  return self.parent_items
end

function Item:add_index()
  if self:container() then return 1 end
  local index = items_util.find_index(self.parent_items, self.id)
  return index and (index + 1) or 1
end

-- Export ---------------------------------------------------------------------

function Item:export_context()
  local fn = kinds[self.kind].export_context
  return fn and fn(self) or nil
end

-- Toggle ---------------------------------------------------------------------

function Item:toggle(state)
  local target = kinds[self.kind].toggle_to
  if not target then
    return false, "Can only toggle chapters and pages"
  end
  self:update(state, { kind = target })
  state:load(state.manuscript.root)
  return true
end

-- Update ---------------------------------------------------------------------

function Item:update(state, attrs)
  if self:container() then
    local index = items_util.find_index(self.parent_items, self.id)
    if not index then return self end
    for k, v in pairs(attrs) do
      if k ~= "items" then
        self[k] = v
        self.parent_items[index][k] = v
      end
    end
    state:save()
    return state.items[self.id]
  end

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

-- Destroy --------------------------------------------------------------------

function Item:destroy_children(state)
  if not self:container() then return end
  for i = #self.items, 1, -1 do
    local child = state.items[self.items[i].id]
    child:destroy_children(state)
    child:destroy(state)
  end
end

function Item:preserve_notes(state)
  if self:container() then return end
  if not self:extras() then return end

  local notes = Path:new(self:notes_path())
  if not notes:exists() then return end

  local content = notes:read()

  if not state.manuscript.orphaned_notes then
    state.manuscript.orphaned_notes = {}
  end

  local item = Item.create("planning_item", state, self:display_name(), state.manuscript.orphaned_notes, 1)
  Path:new(item:text_path()):write(content, "w")
end

function Item:destroy(state)
  if self:container() then
    local index = items_util.find_index(self.parent_items, self.id)
    if not index then return false end
    table.remove(self.parent_items, index)
    state:save()
    return true
  end

  self:preserve_notes(state)

  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      table.remove(self.parent_items, i)
      break
    end
  end

  local doc_dir = Path:new(self:dir_path())
  if doc_dir:exists() then
    vim.fn.delete(doc_dir:absolute(), "rf")
  end

  state:save()
  return true
end

-- Promote children (containers only) ----------------------------------------

function Item:promote_children(state)
  if not self:container() then return end
  local index = items_util.find_index(self.parent_items, self.id)
  if not index then return end

  local children = self.parent_items[index].items or {}

  for i, child in ipairs(children) do
    table.insert(self.parent_items, index + i, child)
  end

  self.parent_items[index].items = {}
  self.items = {}

  state:save()
end

return Item
