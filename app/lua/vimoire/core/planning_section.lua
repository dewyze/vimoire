local SectionBase = require("vimoire.core.section_base")
local add_options = require("vimoire.core.add_options")

local PlanningSection = {}
PlanningSection.__index = PlanningSection
setmetatable(PlanningSection, { __index = SectionBase })

PlanningSection.KIND = "subfolder"
PlanningSection.ADD_OPTIONS = { add_options.PLANNING_ITEM }

function PlanningSection.new(data, root)
  local self = SectionBase.new(data, root)
  setmetatable(self, PlanningSection)
  self.kind = PlanningSection.KIND
  return self
end

function PlanningSection.create(state, name, parent_items, at_index)
  return SectionBase.create_section(PlanningSection, state, name, parent_items, at_index)
end

function PlanningSection:add_options()
  return PlanningSection.ADD_OPTIONS
end

function PlanningSection:category()
  return "planning"
end

return PlanningSection
