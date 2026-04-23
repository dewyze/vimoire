local Entry = {}

local Item = require("vimoire.core.item")
local kinds = require("vimoire.core.kinds")

function Entry.build(data, root)
  local kind = kinds[data.kind] and data.kind or "page"
  return Item.new(kind, data, root)
end

return Entry
