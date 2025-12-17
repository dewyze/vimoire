local M = {}

local external_extensions = { epub = true, docx = true, pdf = true, mobi = true }

function M.open_external(path)
  local cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
  vim.fn.jobstart({ cmd, path }, { detach = true })
end

function M.open_file(path)
  local ext = path:match("%.([^.]+)$")
  if ext and external_extensions[ext] then
    M.open_external(path)
  else
    vim.cmd.edit(path)
  end
end

return M
