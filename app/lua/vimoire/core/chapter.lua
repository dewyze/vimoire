local Chapter = {}

function Chapter.new(data, root)
  local self = setmetatable(data, { __index = Chapter })
  self.root = root
  return self
end

function Chapter:text_path()
  return self.root .. "/chapters/" .. self.id .. "/text.md"
end

function Chapter:notes_path()
  return self.root .. "/chapters/" .. self.id .. "/notes.md"
end

return Chapter
