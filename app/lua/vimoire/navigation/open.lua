local M = {}

function M.open_item(item)
  local path = item:text_path()
  if not path then return end
  vim.cmd("edit " .. path)
  vim.b.vimoire_item_id = item.id
end

return M
