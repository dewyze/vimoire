local Folder = {}
Folder.__index = Folder

function Folder.new(id, name)
  local self = setmetatable({}, Folder)
  self.id = id
  self.name = name
  self.immutable = true
  return self
end

function Folder:destroy(_state)
  -- Folders cannot be deleted
end

return Folder
