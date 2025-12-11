local Folder = {}
Folder.__index = Folder

function Folder.new(id, name, kind, items)
  local self = setmetatable({}, Folder)
  self.id = id
  self.name = name
  self.kind = kind
  self.items = items or {}
  return self
end

function Folder:display_name()
  return self.name
end

function Folder:text_path()
  return nil
end

function Folder:notes_path()
  return nil
end

function Folder:add_parent_items()
  return self.items
end

function Folder:add_index()
  return 1
end

return Folder
