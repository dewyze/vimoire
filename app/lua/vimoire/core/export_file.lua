local ExportFile = {}

local open_util = require("vimoire.util.open")
local scandir = require("plenary.scandir")

function ExportFile.new(id, name, path)
  local self = setmetatable({}, { __index = ExportFile })
  self.id = id
  self.name = name
  self.kind = "export_file"
  self.path = path
  if open_util.is_external(path) then
    self.action = function(s)
      open_util.open_external(s.path)
      return true
    end
  end
  return self
end

function ExportFile:display_name()
  return self.name
end

function ExportFile:display_name_for_path(_filepath)
  return self.name
end

function ExportFile:text_path()
  return self.path
end

function ExportFile:notes_path()      return nil end
function ExportFile:comments_path()   return nil end
function ExportFile:has_notes()       return false end
function ExportFile:has_comments()    return false end

function ExportFile:destroy(state)
  -- Remove from parent folder's items
  if self.parent_items then
    for i, item in ipairs(self.parent_items) do
      if item.id == self.id then
        table.remove(self.parent_items, i)
        break
      end
    end
  end

  -- Delete file
  vim.fn.delete(self.path)

  -- Remove from state
  state.items[self.id] = nil

  return true
end

function ExportFile:category()
  return "export"
end

function ExportFile.scan_folder(state, folder_id, dir_path)
  local items = {}
  local paths = scandir.scan_dir(dir_path, { depth = 1, add_dirs = false, hidden = true, silent = true })
  for _, file_path in ipairs(paths) do
    local name = vim.fs.basename(file_path)
    local file_id = folder_id .. ":" .. name
    local file = ExportFile.new(file_id, name, file_path)
    file.parent_items = items
    state:register(file)
    table.insert(items, { id = file_id })
  end
  table.sort(items, function(a, b)
    return a.id < b.id
  end)
  return items
end

return ExportFile
