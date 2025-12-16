local M = {}

local ManuscriptSection = require("vimoire.core.manuscript_section")
local PlanningSection = require("vimoire.core.planning_section")
local Chapter = require("vimoire.core.chapter")
local Page = require("vimoire.core.page")
local PlanningItem = require("vimoire.core.planning_item")

M.SECTION = {
  label = "Section",
  execute = function(state, name, parent_items, at_index)
    return ManuscriptSection.create(state, name, parent_items, at_index)
  end,
}

M.CHAPTER = {
  label = "Chapter",
  execute = function(state, name, parent_items, at_index)
    return Chapter.create(state, name, parent_items, at_index)
  end,
}

M.PAGE = {
  label = "Page",
  execute = function(state, name, parent_items, at_index)
    return Page.create(state, name, parent_items, at_index)
  end,
}

M.PLANNING_ITEM = {
  label = "Item",
  execute = function(state, name, parent_items, at_index)
    return PlanningItem.create(state, name, parent_items, at_index)
  end,
}

M.SUBFOLDER = {
  label = "Subfolder",
  execute = function(state, name, parent_items, at_index)
    return PlanningSection.create(state, name, parent_items, at_index)
  end,
}

function M.labels(options)
  return vim.tbl_map(function(o) return o.label end, options)
end

function M.find_by_label(options, label)
  for _, opt in ipairs(options) do
    if opt.label == label then
      return opt
    end
  end
end

return M
