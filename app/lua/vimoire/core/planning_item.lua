local PlanningItem = {}
PlanningItem.__index = PlanningItem

local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

function PlanningItem.new(data, item_type, root)
  local self = setmetatable({}, PlanningItem)
  self.id = data.id
  self.name = data.name
  self.file = data.file
  self.type = item_type
  self.root = root
  return self
end

function PlanningItem:full_path()
  return self.root .. "/" .. self.file
end

local function get_manifest_array(manuscript, item_type)
  if item_type == "characters" then
    return manuscript.characters
  elseif item_type == "settings" then
    return manuscript.settings
  elseif item_type == "reference" then
    return manuscript.reference
  end
end

local function generate_filename(name)
  return name:lower():gsub("%s+", "_"):gsub("[^%w_]", "") .. ".md"
end

local function create_item(state, item_type, name, subfolder)
  local manuscript = state.manuscript
  local items = get_manifest_array(manuscript, item_type)

  local existing_ids = {}
  for _, item in ipairs(items) do
    existing_ids[item.id] = true
  end

  local new_id = id_util.generate(existing_ids)
  local filename = generate_filename(name)

  local file_path
  if subfolder then
    file_path = "planning/" .. item_type .. "/" .. subfolder .. "/" .. filename
  else
    file_path = "planning/" .. item_type .. "/" .. filename
  end

  local data = {
    id = new_id,
    name = name,
    file = file_path,
  }

  -- Create directory and file
  local full_path = manuscript.root .. "/" .. file_path
  local dir = Path:new(full_path):parent()
  dir:mkdir({ parents = true })
  Path:new(full_path):write("# " .. name .. "\n", "w")

  -- Add to manifest
  table.insert(items, data)
  manuscript:save()

  return PlanningItem.new(data, item_type, manuscript.root)
end

function PlanningItem.create_character(state, name, subfolder)
  return create_item(state, "characters", name, subfolder)
end

function PlanningItem.create_setting(state, name, subfolder)
  return create_item(state, "settings", name, subfolder)
end

function PlanningItem.create_reference(state, name, subfolder)
  return create_item(state, "reference", name, subfolder)
end

function PlanningItem:update(state, attrs)
  local items = get_manifest_array(state.manuscript, self.type)

  for _, item in ipairs(items) do
    if item.id == self.id then
      if attrs.name then
        item.name = attrs.name
        self.name = attrs.name
      end
      break
    end
  end

  state.manuscript:save()
end

function PlanningItem:destroy(state)
  local items = get_manifest_array(state.manuscript, self.type)

  -- Remove file
  Path:new(self:full_path()):rm()

  -- Remove from manifest
  for i, item in ipairs(items) do
    if item.id == self.id then
      table.remove(items, i)
      break
    end
  end

  state.manuscript:save()
end

return PlanningItem
