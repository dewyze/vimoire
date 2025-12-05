local Subfolder = {}
Subfolder.__index = Subfolder

local Path = require("plenary.path")

function Subfolder.new(id, name, path, planning_type)
  local self = setmetatable({}, Subfolder)
  self.id = id
  self.name = name
  self.path = path
  self.planning_type = planning_type
  return self
end

function Subfolder:destroy(state)
  local manifest_array = state.manuscript[self.planning_type] or {}

  -- Remove items in this subfolder from manifest
  local prefix = "planning/" .. self.planning_type .. "/" .. self.name:lower() .. "/"
  for i = #manifest_array, 1, -1 do
    if manifest_array[i].file:sub(1, #prefix) == prefix then
      table.remove(manifest_array, i)
    end
  end

  -- Delete directory
  local dir = Path:new(self.path)
  if dir:exists() then
    vim.fn.delete(self.path, "rf")
  end

  state:save()
end

return Subfolder
