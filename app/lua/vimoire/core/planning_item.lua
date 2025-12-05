local PlanningItem = {}
PlanningItem.__index = PlanningItem

local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

function PlanningItem.new(data, planning_type, base_path)
  local self = setmetatable({}, PlanningItem)
  self.id = data.id
  self.name = data.name
  self.file = data.file
  self.type = planning_type
  self.base_path = base_path
  return self
end

function PlanningItem:text_path()
  return self.base_path .. "/" .. self.file
end

function PlanningItem:display_name()
  return self.name
end

local function generate_filename(name)
  return name:lower():gsub("%s+", "_"):gsub("[^%w_]", "") .. ".md"
end

local function create_item(state, planning_type, name, parent_items, base_path)
  local new_id = id_util.generate(state.items)
  local filename = generate_filename(name)

  local data = {
    id = new_id,
    name = name,
    file = filename,
  }

  -- Create file
  local full_path = base_path .. "/" .. filename
  local dir = Path:new(full_path):parent()
  dir:mkdir({ parents = true })
  Path:new(full_path):write("# " .. name .. "\n", "w")

  -- Add to parent items array
  table.insert(parent_items, data)
  state:save()

  return state.items[new_id]
end

function PlanningItem.create_character(state, name, parent_items, base_path)
  return create_item(state, "characters", name, parent_items, base_path)
end

function PlanningItem.create_setting(state, name, parent_items, base_path)
  return create_item(state, "settings", name, parent_items, base_path)
end

function PlanningItem.create_reference(state, name, parent_items, base_path)
  return create_item(state, "reference", name, parent_items, base_path)
end

function PlanningItem:update(state, attrs)
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      if attrs.name then
        item.name = attrs.name
        self.name = attrs.name
      end
      break
    end
  end

  state:save()
end

function PlanningItem:destroy(state)
  -- Remove file
  Path:new(self:text_path()):rm()

  -- Remove from parent items
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      table.remove(self.parent_items, i)
      break
    end
  end

  state:save()
end

return PlanningItem
