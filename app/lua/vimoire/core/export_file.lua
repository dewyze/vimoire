local ExportFile = {}

function ExportFile.new(id, name, path)
  local self = setmetatable({}, { __index = ExportFile })
  self.id = id
  self.name = name
  self.kind = "export_file"
  self.path = path
  self.immutable = true
  return self
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

return ExportFile
