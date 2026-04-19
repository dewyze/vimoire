local ExportFile = {}

local open_util = require("vimoire.util.open")

function ExportFile.new(id, name, path)
  local self = setmetatable({}, { __index = ExportFile })
  self.id = id
  self.name = name
  self.kind = "export_file"
  self.path = path
  return self
end

function ExportFile:action()
  open_util.open_file(self.path)
  return true
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

function ExportFile:notes_path()
  return nil
end

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
  local handle = vim.loop.fs_scandir(dir_path)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == "file" then
        local file_id = folder_id .. ":" .. name
        local file_path = dir_path .. "/" .. name
        local file = ExportFile.new(file_id, name, file_path)
        file.parent_items = items
        state:register(file)
        table.insert(items, { id = file_id })
      end
    end
  end
  table.sort(items, function(a, b)
    return a.id < b.id
  end)
  return items
end

return ExportFile
