local M = {}

function M.find_index(items, id)
  for i, item in ipairs(items) do
    if item.id == id then return i end
  end
end

return M
