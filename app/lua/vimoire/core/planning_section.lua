local SectionBase = require("vimoire.core.section_base")

local PlanningSection = {}
PlanningSection.__index = PlanningSection
setmetatable(PlanningSection, { __index = SectionBase })

PlanningSection.KIND = "subfolder"

function PlanningSection.new(data, root)
  local self = SectionBase.new(data, root)
  setmetatable(self, PlanningSection)
  self.kind = PlanningSection.KIND
  return self
end

function PlanningSection.create(state, name, parent_items, at_index)
  return SectionBase.create_section(PlanningSection, state, name, parent_items, at_index)
end

return PlanningSection
