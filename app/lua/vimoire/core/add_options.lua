local M = {}

local items_util = require("vimoire.util.items")

M.SECTION = {
  label = "Section",
  execute = function(state, name, parent_items, at_index)
    local Item = require("vimoire.core.item")
    return Item.create("section", state, name, parent_items, at_index)
  end,
  -- Sections always insert at manuscript root level
  target = function(state, item)
    local ms_items = state.manuscript.items
    if item.parent_section then
      -- Item is inside a section: insert after that section
      local section_index = items_util.find_index(ms_items, item.parent_section.id)
      return ms_items, (section_index or #ms_items) + 1
    elseif item.parent_items == ms_items then
      -- Item is at manuscript root: insert after it
      local item_index = items_util.find_index(ms_items, item.id)
      return ms_items, (item_index or #ms_items) + 1
    else
      -- Fallback: end of manuscript
      return ms_items, #ms_items + 1
    end
  end,
}

M.CHAPTER = {
  label = "Chapter",
  execute = function(state, name, parent_items, at_index)
    local Chapter = require("vimoire.core.chapter")
    return Chapter.create(state, name, parent_items, at_index)
  end,
}

M.PAGE = {
  label = "Page",
  execute = function(state, name, parent_items, at_index)
    local Page = require("vimoire.core.page")
    return Page.create(state, name, parent_items, at_index)
  end,
}

M.PLANNING_ITEM = {
  label = "Item",
  execute = function(state, name, parent_items, at_index)
    local Item = require("vimoire.core.item")
    return Item.create("planning_item", state, name, parent_items, at_index)
  end,
}

M.SUBFOLDER = {
  label = "Subfolder",
  execute = function(state, name, parent_items, at_index)
    local PlanningSection = require("vimoire.core.planning_section")
    return PlanningSection.create(state, name, parent_items, at_index)
  end,
}

M.PLOTTING_BOARD = {
  label = "Board",
  execute = function(state, name, parent_items, at_index)
    local Board = require("vimoire.plotting.board")
    return Board.create(state, name, parent_items, at_index)
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
