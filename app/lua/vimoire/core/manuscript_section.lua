local SectionBase = require("vimoire.core.section_base")

local ManuscriptSection = {}
ManuscriptSection.__index = ManuscriptSection
setmetatable(ManuscriptSection, { __index = SectionBase })

ManuscriptSection.KIND = "section"

function ManuscriptSection.new(data, root)
  local self = SectionBase.new(data, root)
  setmetatable(self, ManuscriptSection)
  self.kind = ManuscriptSection.KIND
  return self
end

function ManuscriptSection.create(state, name, parent_items, at_index)
  return SectionBase.create_section(ManuscriptSection, state, name, parent_items, at_index)
end

return ManuscriptSection
