-- Vimoire statusline
-- Context-aware statusline with path, word count (current/total), and location

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

  -- Left side: context path
  local left = components.context_path(item, filepath)

  -- Right side: word count (current/total) and location
  local right_parts = {}

  local wc = components.word_count()
  local book_wc = components.book_word_count()
  if wc ~= "" and book_wc ~= "" then
    table.insert(right_parts, wc .. " / " .. book_wc)
  elseif wc ~= "" then
    table.insert(right_parts, wc)
  end

  table.insert(right_parts, components.location())

  local right = table.concat(right_parts, " │ ")

  -- Build final statusline with highlight
  return string.format("%%#%s# %s%%=  %s ", hl, left, right)
end

-- Check if current buffer is neo-tree
local function is_neotree_buffer()
  local bufname = vim.api.nvim_buf_get_name(0)
  return bufname:match("neo%-tree [%w]+ %[%d+%]$")
end

-- Update statusline for current window
local function update_statusline()
  if is_neotree_buffer() then
    local title = state.book and state.book.title or "Vimoire"
    vim.wo.statusline = "%#StatusLine# " .. title
    vim.wo.winbar = nil
    return
  end
  vim.wo.statusline = build_statusline()
end

-- Refresh components that need updating
local function refresh()
  components.refresh_book_word_count()
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
    callback = function()
      -- Refresh book total if this is a prose file
      local ft = vim.bo.filetype
      if ft == "vimoire_prose" or ft == "vimoire_markdown" then
        components.refresh_book_word_count()
      end
      update_statusline()
    end,
  })

  -- Initial refresh
  refresh()
end

return M
