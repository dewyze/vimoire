local Folder = {}
Folder.__index = Folder

function Folder.new(id, name, kind, items, opts)
  opts = opts or {}
  local self = setmetatable({}, Folder)
  self.id = id
  self.name = name
  self.kind = kind
  self.immutable = true
  self.items = items or {}
  self._add_options = opts.add_options
  return self
end

function Folder:action()
  return false
end

function Folder:display_name()
  return self.name
end

function Folder:text_path()
  return nil
end

function Folder:notes_path()     return nil end
function Folder:comments_path()  return nil end
function Folder:has_notes()      return false end
function Folder:has_comments()   return false end
-- TODO: Folder is structurally close to ContainerItem (synthetic container, no files).
-- Consider unifying as a synthetic ContainerItem — see TODO.md: declarative synthetic-folder table.

function Folder:add_parent_items()
  return self.items
end

function Folder:add_index()
  return 1
end

function Folder:toggle(_state)
  return false, "Can only toggle chapters and pages"
end

function Folder:add_options()
  return self._add_options
end

function Folder:category()
  return "default"
end

return Folder
