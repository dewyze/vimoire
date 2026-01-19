local SectionBase = require("vimoire.core.section_base")
local add_options = require("vimoire.core.add_options")

local ManuscriptSection = {}
ManuscriptSection.__index = ManuscriptSection
setmetatable(ManuscriptSection, { __index = SectionBase })

ManuscriptSection.KIND = "section"
ManuscriptSection.ADD_OPTIONS = { add_options.CHAPTER, add_options.PAGE, add_options.SECTION }

function ManuscriptSection.new(data, root)
  local self = SectionBase.new(data, root)
  setmetatable(self, ManuscriptSection)
  self.kind = ManuscriptSection.KIND
  return self
end

function ManuscriptSection.create(state, name, parent_items, at_index)
  return SectionBase.create_section(ManuscriptSection, state, name, parent_items, at_index)
end

function ManuscriptSection:add_options()
  return ManuscriptSection.ADD_OPTIONS
end

return ManuscriptSection
