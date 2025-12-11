local Entry = {}

local ManuscriptSection = require("vimoire.core.manuscript_section")
local Chapter = require("vimoire.core.chapter")
local Page = require("vimoire.core.page")

local KINDS = {
  section = ManuscriptSection,
  chapter = Chapter,
  page = Page,
}

function Entry.build(data, root)
  local class = KINDS[data.kind] or Page
  return class.new(data, root)
end

return Entry
