-- Vimoire statusline
-- Context-aware statusline with branch, path, word count, and location

local M = {}

local state = require("vimoire.state")
local colors = require("vimoire.statusline.colors")
local components = require("vimoire.statusline.components")

-- Build statusline string for current buffer
local function build_statusline()
  local filepath = vim.fn.expand("%:p")
  local item = state.paths[filepath]
  local context = components.get_context(item, filepath)
  local hl = colors.HIGHLIGHTS[context]

  local parts = {}

  -- Left side: branch and context path
  local branch = components.branch()
  if branch ~= "" then
    table.insert(parts, branch)
  end

  local path = components.context_path(item, filepath)
  table.insert(parts, path)

  local left = table.concat(parts, " │ ")

  -- Right side: word count and location
  local right_parts = {}

  local wc = components.word_count()
  if wc ~= "" then
    table.insert(right_parts, wc)
  end

  table.insert(right_parts, components.location())

  local right = table.concat(right_parts, " │ ")

  -- Build final statusline with highlight
  return string.format("%%#%s# %s%%=  %s ", hl, left, right)
end

-- Update statusline for current window
local function update_statusline()
  vim.wo.statusline = build_statusline()
end

-- Refresh components that need updating
local function refresh()
  components.refresh_branch()
  update_statusline()
end

function M.setup()
  colors.setup()

  local augroup = vim.api.nvim_create_augroup("VimoireStatusline", { clear = true })

  -- Refresh on buffer/window changes
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = augroup,
    callback = refresh,
  })

  -- Update on cursor move (for word count in visual mode)
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = augroup,
    callback = update_statusline,
  })

  -- Update after save (word count may change)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    callback = update_statusline,
  })

  -- Hide statusline for neo-tree
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "neo-tree",
    callback = function()
      vim.wo.statusline = " "
    end,
  })

  -- Initial refresh
  refresh()
end

return M
