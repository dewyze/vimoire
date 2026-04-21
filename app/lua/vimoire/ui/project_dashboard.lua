-- Project dashboard (shown when :ViewHome called with project loaded)
local M = {}

local state = require("vimoire.state")
local stats = require("vimoire.stats")

M.buf = nil
M.win = nil

-- Format number with commas
local function format_number(n)
  return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Format session delta with sign
local function format_delta(n)
  if n > 0 then
    return "+" .. format_number(n)
  elseif n < 0 then
    return format_number(n)
  else
    return "0"
  end
end

local function center_text(text, width)
  local padding = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
  return string.rep(" ", math.max(0, padding)) .. text
end

local function render()
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
    return
  end

  local width = vim.api.nvim_win_get_width(M.win or 0)
  local lines = {}
  local highlights = {}

  local book = state.book

  -- Spacing at top
  table.insert(lines, "")
  table.insert(lines, "")
  table.insert(lines, "")

  -- Book title
  local title = book and book.title or "Untitled"
  local title_line = center_text(title, width)
  table.insert(lines, title_line)
  table.insert(highlights, { line = #lines - 1, hl = "VimoireLogo" })

  -- Author (if present)
  if book and book.author and book.author ~= "" then
    table.insert(lines, "")
    local author_line = center_text("by " .. book.author, width)
    table.insert(lines, author_line)
    table.insert(highlights, { line = #lines - 1, hl = "VimoireTagline" })
  end

  table.insert(lines, "")
  table.insert(lines, "")

  -- Stats summary
  local session = stats.session_words()
  local session_line = center_text("Session         " .. format_delta(session) .. " words", width)
  table.insert(lines, session_line)
  table.insert(highlights, { line = #lines - 1, hl = "Normal" })

  -- Total / progress
  local progress = stats.progress()
  if progress then
    local prog_line = center_text(
      "Total           " .. format_number(progress.current) .. " / " .. format_number(progress.target) .. " (" .. progress.percent .. "%)",
      width
    )
    table.insert(lines, prog_line)
    table.insert(highlights, { line = #lines - 1, hl = "Normal" })
  else
    local book_words = stats.calculate_book_words()
    local pages = stats.estimated_pages()
    local total_line = center_text("Total           " .. format_number(book_words) .. " words (" .. pages .. " pages)", width)
    table.insert(lines, total_line)
    table.insert(highlights, { line = #lines - 1, hl = "Normal" })
  end

  table.insert(lines, "")
  table.insert(lines, "")

  -- Actions
  local actions = {
    { key = "s", desc = "Full stats" },
    { key = "q", desc = "Close" },
  }

  for _, action in ipairs(actions) do
    local action_line = center_text("[" .. action.key .. "] " .. action.desc, width)
    table.insert(lines, action_line)
    table.insert(highlights, { line = #lines - 1, hl = "VimoireAction" })
  end

  table.insert(lines, "")

  -- Write to buffer
  vim.api.nvim_buf_set_option(M.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M.buf, "modifiable", false)

  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("vimoire_project_dashboard")
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(M.buf, ns, hl.hl, hl.line, 0, -1)
  end
end

local function setup_keymaps()
  local opts = { buffer = M.buf, nowait = true, silent = true }

  vim.keymap.set("n", "s", function()
    M.hide()
    require("vimoire.ui.stats_window").show()
  end, opts)

  vim.keymap.set("n", "q", function()
    M.hide()
  end, opts)

  vim.keymap.set("n", "<Esc>", function()
    M.hide()
  end, opts)
end

function M.show()
  -- Create buffer
  M.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(M.buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(M.buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(M.buf, "swapfile", false)
  vim.api.nvim_buf_set_name(M.buf, "vimoire://project")

  -- Use current window
  M.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.win, M.buf)

  -- Window options
  vim.api.nvim_win_set_option(M.win, "number", false)
  vim.api.nvim_win_set_option(M.win, "relativenumber", false)
  vim.api.nvim_win_set_option(M.win, "signcolumn", "no")
  vim.api.nvim_win_set_option(M.win, "cursorline", false)

  setup_keymaps()
  render()
end

function M.hide()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
  end
  M.buf = nil
  M.win = nil
end

return M
