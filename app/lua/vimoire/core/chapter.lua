local Chapter = {}

function Chapter.new(data)
  local self = setmetatable(data, { __index = Chapter })
  return self
end

return Chapter
