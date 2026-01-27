local M = {}

local popup_win = nil
local popup_buf = nil

local function close_popup()
  if popup_win and vim.api.nvim_win_is_valid(popup_win) then
    vim.api.nvim_win_close(popup_win, true)
  end
  if popup_buf and vim.api.nvim_buf_is_valid(popup_buf) then
    vim.api.nvim_buf_delete(popup_buf, { force = true })
  end
  popup_win = nil
  popup_buf = nil
end

function M.show_popup(comment)
  close_popup()

  if not comment or not comment.text then
    return
  end

  local lines = vim.split(comment.text, "\n")
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, #line)
  end

  popup_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, lines)
  vim.bo[popup_buf].modifiable = false

  local width = math.min(60, max_width + 2)
  local height = math.min(10, #lines)

  popup_win = vim.api.nvim_open_win(popup_buf, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  -- Close on cursor move
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = close_popup,
  })
end

function M.close_popup()
  close_popup()
end

return M
