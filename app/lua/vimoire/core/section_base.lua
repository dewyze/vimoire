local SectionBase = {}
SectionBase.__index = SectionBase

local id_util = require("vimoire.util.id")
local items_util = require("vimoire.util.items")

function SectionBase.new(data, root)
  local self = setmetatable({}, SectionBase)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.root = root
  self.kind = data.kind or "section"
  self.items = self.items or {}
  return self
end

function SectionBase.create_section(class, state, name, parent_items, at_index)
  local new_id = id_util.generate(state.items)

  local data = { id = new_id, kind = class.KIND, name = name, items = {} }
  table.insert(parent_items, at_index, data)

  state:save()
  return state.items[new_id]
end

function SectionBase:action()
  return false
end

function SectionBase:text_path()
  return nil
end

function SectionBase:notes_path()
  return nil
end

function SectionBase:display_number()
  return nil
end

function SectionBase:display_name()
  return self.name
end

function SectionBase:add_parent_items()
  return self.items
end

function SectionBase:add_index()
  return 1
end

function SectionBase:update(state, attrs)
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

function SectionBase:promote_children(state)
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

function SectionBase:destroy_children(state)
  for i = #self.items, 1, -1 do
    local child = state.items[self.items[i].id]
    child:destroy_children(state)
    child:destroy(state)
  end
end

function SectionBase:destroy(state)
  local index = items_util.find_index(self.parent_items, self.id)
  if not index then return false end

  table.remove(self.parent_items, index)

  state:save()
  return true
end

function SectionBase:toggle(_state)
  return false, "Can only toggle chapters and pages"
end

return SectionBase
