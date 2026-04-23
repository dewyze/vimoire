local Path = require("plenary.path")

local kinds = require("vimoire.core.kinds")
local id_util = require("vimoire.util.id")
local items_util = require("vimoire.util.items")

local FILE_DISPLAY_SUFFIXES = {
  ["notes.md"] = " - Notes",
}

-- DocumentItem -----------------------------------------------------------------

local DocumentItem = {}
DocumentItem.__index = DocumentItem

function DocumentItem:container() return false end

function DocumentItem:base()        return kinds[self.kind].base end
function DocumentItem:extras()      return kinds[self.kind].extras == true end
function DocumentItem:category()    return kinds[self.kind].category end
function DocumentItem:numbered()    return kinds[self.kind].numbered == true end
function DocumentItem:add_options() return kinds[self.kind].add_options end

function DocumentItem:dir_path()
  return self.root .. "/" .. self:base() .. "/" .. self.id
end

function DocumentItem:text_path()
  local filename = kinds[self.kind].text_filename
  if not filename then return nil end
  return self:dir_path() .. "/" .. filename
end

function DocumentItem:notes_path()
  if not self:extras() then return nil end
  return self:dir_path() .. "/notes.md"
end

function DocumentItem:display_number()
  return self.chapter_index and tostring(self.chapter_index) or nil
end

function DocumentItem:display_name()
  local num = self:display_number()
  if num then return num .. ": " .. self.name end
  return self.name
end

function DocumentItem:display_name_for_path(filepath)
  local filename = filepath:match("([^/]+)$")
  local suffix = FILE_DISPLAY_SUFFIXES[filename] or ""
  return self:display_name() .. suffix
end

function DocumentItem:action() return false end

function DocumentItem:add_parent_items() return self.parent_items end

function DocumentItem:add_index()
  local index = items_util.find_index(self.parent_items, self.id)
  return index and (index + 1) or 1
end

function DocumentItem:export_context()
  local fn = kinds[self.kind].export_context
  return fn and fn(self) or nil
end

function DocumentItem:toggle(state)
  local target = kinds[self.kind].toggle_to
  if not target then
    return false, "Can only toggle chapters and pages"
  end
  self:update(state, { kind = target })
  state:load(state.manuscript.root)
  return true
end

function DocumentItem:update(state, attrs)
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

function DocumentItem:preserve_notes(state)
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

function DocumentItem:destroy(state)
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

-- ContainerItem ----------------------------------------------------------------

local ContainerItem = {}
ContainerItem.__index = ContainerItem

function ContainerItem:container() return true end

function ContainerItem:base()        return kinds[self.kind].base end
function ContainerItem:extras()      return kinds[self.kind].extras == true end
function ContainerItem:category()    return kinds[self.kind].category end
function ContainerItem:numbered()    return kinds[self.kind].numbered == true end
function ContainerItem:add_options() return kinds[self.kind].add_options end

function ContainerItem:dir_path()       return nil end
function ContainerItem:text_path()      return nil end
function ContainerItem:notes_path()     return nil end
function ContainerItem:display_number() return nil end

function ContainerItem:display_name() return self.name end

function ContainerItem:display_name_for_path(filepath)
  local filename = filepath:match("([^/]+)$")
  local suffix = FILE_DISPLAY_SUFFIXES[filename] or ""
  return self:display_name() .. suffix
end

function ContainerItem:action() return false end

function ContainerItem:add_parent_items() return self.items end
function ContainerItem:add_index()        return 1 end

function ContainerItem:export_context()
  local fn = kinds[self.kind].export_context
  return fn and fn(self) or nil
end

function ContainerItem:toggle(state)
  local target = kinds[self.kind].toggle_to
  if not target then
    return false, "Can only toggle chapters and pages"
  end
  self:update(state, { kind = target })
  state:load(state.manuscript.root)
  return true
end

function ContainerItem:update(state, attrs)
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

function ContainerItem:destroy_children(state)
  for i = #self.items, 1, -1 do
    local child = state.items[self.items[i].id]
    child:destroy_children(state)
    child:destroy(state)
  end
end

function ContainerItem:destroy(state)
  local index = items_util.find_index(self.parent_items, self.id)
  if not index then return false end
  table.remove(self.parent_items, index)
  state:save()
  return true
end

function ContainerItem:promote_children(state)
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

-- Item (dispatch) --------------------------------------------------------------

local Item = {}

function Item.new(kind, data, root)
  local mt = kinds[kind].container and ContainerItem or DocumentItem
  local self = setmetatable({}, mt)

  if kinds[kind].container then
    for k, v in pairs(data) do self[k] = v end
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
    table.insert(parent_items, at_index, { id = new_id, kind = kind, name = name, items = {} })
  else
    local doc_dir = Path:new(state.manuscript.root, config.base, new_id)
    doc_dir:mkdir({ parents = true })
    local text_file = Path:new(doc_dir:absolute(), config.text_filename)
    local frontmatter = string.format("---\ntitle: %s\n# subtitle: \n# epigraph: \n---\n\n", name)
    text_file:write(frontmatter, "w")
    table.insert(parent_items, at_index, { id = new_id, name = name, kind = kind })
  end

  state:save()
  return state.items[new_id]
end

return Item
