local M = {}

-- Drop-in for vim.ui.select that skips the picker and calls on_choice
-- immediately when there is only one item.
function M.select(items, opts, on_choice)
  if #items == 1 then
    vim.schedule(function() on_choice(items[1], 1) end)
    return
  end
  vim.ui.select(items, opts, on_choice)
end

return M
