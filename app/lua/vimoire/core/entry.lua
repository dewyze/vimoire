local Entry = {}

local Chapter = require("vimoire.core.chapter")
local Page = require("vimoire.core.page")
local Item = require("vimoire.core.item")

local KINDS = {
  section = function(data, root) return Item.new("section", data, root) end,
  chapter = function(data, root) return Chapter.new(data, root) end,
  page = function(data, root) return Page.new(data, root) end,
}

function Entry.build(data, root)
  local handler = KINDS[data.kind] or KINDS.page
  return handler(data, root)
end

return Entry
