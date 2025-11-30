local Section = {}

function Section.new(data)
  local self = setmetatable(data, { __index = Section })
  return self
end

return Section
