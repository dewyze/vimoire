local DocumentBase = require("vimoire.core.document_base")

local PlanningItem = {}
PlanningItem.__index = PlanningItem
setmetatable(PlanningItem, { __index = DocumentBase })

PlanningItem.KIND = "planning_item"
PlanningItem.BASE = "planning"

function PlanningItem.new(data, root)
  local self = DocumentBase.new(data, root)
  setmetatable(self, PlanningItem)
  self.kind = PlanningItem.KIND
  return self
end

function PlanningItem.create(state, name, parent_items, at_index)
  return DocumentBase.create_document(PlanningItem, state, name, parent_items, at_index)
end

function PlanningItem:base()
  return PlanningItem.BASE
end

function PlanningItem:extras()
  return false
end

return PlanningItem
