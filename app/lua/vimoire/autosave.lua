-- Autosave for Vimoire buffers
-- Saves on CursorHold, InsertLeave, and BufLeave

local M = {}

local config = require("vimoire.config")

local function should_save()
  -- Only save modified, normal buffers with a filename
  return vim.bo.modified
    and vim.bo.buftype == ""
    and vim.fn.expand("%") ~= ""
end

local function save()
  if should_save() then
    vim.cmd("silent! write")
  end
end

function M.setup()
  if not config.get("editor.autosave") then
    return
  end

  local augroup = vim.api.nvim_create_augroup("VimoireAutosave", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave", "BufLeave" }, {
    group = augroup,
    pattern = "*.md",
    callback = save,
  })
end

return M
