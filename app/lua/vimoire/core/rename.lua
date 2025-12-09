local M = {}

function M.validate(new_name, item)
  if not new_name or new_name:match("^%s*$") then
    return false, "Name cannot be empty"
  end

  for _, sibling in ipairs(item.parent_items) do
    if sibling.id ~= item.id and sibling.name == new_name then
      return false, "Name already exists"
    end
  end

  return true
end

function M.execute(item, state, new_name)
  if item.immutable then
    return false, "Cannot rename this item"
  end

  local ok, err = M.validate(new_name, item)
  if not ok then
    return false, err
  end

  item:update(state, { name = new_name })
  return true
end

return M
