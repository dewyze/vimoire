local M = {}

function M.open_item(item)
  local path = item:text_path()
  vim.cmd("edit " .. path)
  vim.b.vimoire_item_id = item.id
end

return M
