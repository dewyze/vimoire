local M = {}

local external_extensions = { epub = true, docx = true, pdf = true, mobi = true }

function M.is_external(path)
  local ext = path:match("%.([^.]+)$")
  return ext ~= nil and external_extensions[ext] == true
end

function M.open_external(path)
  local cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
  vim.fn.jobstart({ cmd, path }, { detach = true })
end

function M.focus_or_edit(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 then
    local win_id = vim.fn.bufwinid(bufnr)
    if win_id ~= -1 then
      vim.api.nvim_set_current_win(win_id)
      return
    end
  end
  vim.cmd.edit(path)
end

function M.open_file(path)
  if M.is_external(path) then
    M.open_external(path)
  else
    M.focus_or_edit(path)
  end
end

return M
