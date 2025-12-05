local Subfolder = {}
Subfolder.__index = Subfolder

local Path = require("plenary.path")

function Subfolder.new(data, planning_type, base_path)
  local self = setmetatable({}, Subfolder)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.kind = "subfolder"
  self.planning_type = planning_type
  self.base_path = base_path
  self.items = self.items or {}
  return self
end

function Subfolder:dir_path()
  return self.base_path .. "/" .. self.name:lower()
end

function Subfolder:text_path()
  return nil
end

function Subfolder:display_name()
  return self.name
end

function Subfolder:destroy(state)
  local manifest_array = state.manuscript[self.planning_type] or {}
  local index = nil
  for i, item in ipairs(manifest_array) do
    if item.id == self.id then
      index = i
      break
    end
  end
  if not index then return false end

  -- Remove subfolder from manifest
  table.remove(manifest_array, index)

  -- Delete directory
  local dir = Path:new(self:dir_path())
  if dir:exists() then
    vim.fn.delete(self:dir_path(), "rf")
  end

  state:save()
  return true
end

return Subfolder
