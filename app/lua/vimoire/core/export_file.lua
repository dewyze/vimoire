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

return ExportFile
