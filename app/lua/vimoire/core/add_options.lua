local M = {}

local Section = require("vimoire.core.section")
local Document = require("vimoire.core.document")

M.SECTION = {
  label = "Section",
  execute = function(state, name, parent_items)
    return Section.create(state, name, parent_items)
  end,
}

M.CHAPTER = {
  label = "Chapter",
  execute = function(state, name, parent_items)
    return Document.create(state, name, parent_items, { kind = "chapter" })
  end,
}

M.PAGE = {
  label = "Page",
  execute = function(state, name, parent_items)
    return Document.create(state, name, parent_items, { kind = "page" })
  end,
}

M.PLANNING_ITEM = {
  label = "Item",
  execute = function(state, name, parent_items)
    return Document.create(state, name, parent_items, { kind = "planning_item", base = "planning" })
  end,
}

M.SUBFOLDER = {
  label = "Subfolder",
  execute = function(state, name, parent_items)
    return Section.create(state, name, parent_items)
  end,
}

M.CANCEL = {
  label = "Cancel",
  execute = function()
    return nil
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
