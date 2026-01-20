local DocumentBase = require("vimoire.core.document_base")
local add_options = require("vimoire.core.add_options")

local PlanningItem = {}
PlanningItem.__index = PlanningItem
setmetatable(PlanningItem, { __index = DocumentBase })

PlanningItem.KIND = "planning_item"
PlanningItem.BASE = "planning"
PlanningItem.TEXT_FILENAME = "text.md"
PlanningItem.ADD_OPTIONS = { add_options.PLANNING_ITEM }

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

function PlanningItem:text_path()
  return self:dir_path() .. "/" .. PlanningItem.TEXT_FILENAME
end

function PlanningItem:add_options()
  return PlanningItem.ADD_OPTIONS
end

function PlanningItem:category()
  return "planning"
end

return PlanningItem
