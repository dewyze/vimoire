local Section = {}

function Section.new(data, root_path)
  local self = setmetatable(data, { __index = Section })
  self._root = root_path
  return self
end

function Section:chapters()
  local state = require("vimoire.state")
  return state.chapters_by_section[self.id]
end

return Section
