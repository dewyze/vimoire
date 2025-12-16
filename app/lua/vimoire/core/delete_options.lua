local M = {}

M.DELETE = {
  label = function(_item) return "Delete" end,
  execute = function(item, state)
    return item:destroy(state)
  end,
}

M.KEEP_CONTENTS = {
  label = function(item) return "Delete '" .. item.name .. "', keep contents" end,
  execute = function(item, state)
    item:promote_children(state)
    return item:destroy(state)
  end,
}

M.DELETE_WITH_CONTENTS = {
  label = function(item) return "Delete '" .. item.name .. "' and contents" end,
  execute = function(item, state)
    item:destroy_children(state)
    return item:destroy(state)
  end,
}

function M.for_item(item)
  if item.immutable then
    vim.notify("Cannot delete " .. item.name, vim.log.levels.WARN)
    return nil
  end
  if item.items and #item.items > 0 then
    return { choose = { M.KEEP_CONTENTS, M.DELETE_WITH_CONTENTS } }
  end
  return { confirm = M.DELETE }
end

function M.labels(options, item)
  return vim.tbl_map(function(o) return o.label(item) end, options)
end

function M.find_by_label(options, label, item)
  for _, opt in ipairs(options) do
    if opt.label(item) == label then
      return opt
    end
  end
end

return M
