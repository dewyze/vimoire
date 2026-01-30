-- Stats floating window
local M = {}

local stats = require("vimoire.stats")
local state = require("vimoire.state")

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

-- Center text in given width
local function center(text, width)
  local padding = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
  return string.rep(" ", math.max(0, padding)) .. text
end

-- Right-align text in given width
local function right_align(text, width)
  local padding = width - vim.fn.strdisplaywidth(text)
  return string.rep(" ", math.max(0, padding)) .. text
end

-- Build stats content
local function build_content(width)
  local lines = {}
  local highlights = {} -- {line, col_start, col_end, hl_group}

  local inner_width = width - 4 -- padding

  -- Header
  table.insert(lines, "")
  local header = "Book Stats"
  table.insert(lines, center(header, width))
  table.insert(highlights, { #lines, math.floor((width - #header) / 2), math.floor((width - #header) / 2) + #header, "Title" })
  table.insert(lines, "")

  -- Session words
  local session = stats.session_words()
  local session_label = "Session"
  local session_value = format_delta(session) .. " words"
  local session_line = "  " .. session_label .. string.rep(" ", inner_width - #session_label - #session_value) .. session_value
  table.insert(lines, session_line)

  -- Book total
  local book_words = stats.calculate_book_words()
  local pages = stats.estimated_pages()
  local total_label = "Book Total"
  local total_value = format_number(book_words) .. " words (" .. pages .. " pages)"
  local total_line = "  " .. total_label .. string.rep(" ", inner_width - #total_label - #total_value) .. total_value
  table.insert(lines, total_line)

  -- Progress (if goal set)
  local progress = stats.progress()
  if progress then
    local prog_label = "Progress"
    local prog_value = format_number(progress.current) .. " / " .. format_number(progress.target) .. " (" .. progress.percent .. "%)"
    local prog_line = "  " .. prog_label .. string.rep(" ", inner_width - #prog_label - #prog_value) .. prog_value
    table.insert(lines, prog_line)
  end

  -- Daily progress (if goal set)
  local daily = stats.daily_progress()
  if daily then
    local daily_label = "Daily Goal"
    local daily_value = format_number(daily.written) .. " / " .. format_number(daily.goal) .. " (" .. daily.percent .. "%)"
    local daily_line = "  " .. daily_label .. string.rep(" ", inner_width - #daily_label - #daily_value) .. daily_value
    table.insert(lines, daily_line)
  end

  table.insert(lines, "")

  -- Breakdown header
  local breakdown_header = "Breakdown"
  table.insert(lines, center(breakdown_header, width))
  table.insert(highlights, { #lines, math.floor((width - #breakdown_header) / 2), math.floor((width - #breakdown_header) / 2) + #breakdown_header, "Title" })
  table.insert(lines, "")

  -- Chapter breakdown
  local breakdown = stats.chapter_breakdown()
  local current_section = nil

  for _, entry in ipairs(breakdown) do
    -- Section header if changed
    if entry.section_name ~= current_section then
      current_section = entry.section_name
      if current_section then
        table.insert(lines, "  " .. current_section)
        table.insert(highlights, { #lines, 2, 2 + #current_section, "Directory" })
      end
    end

    -- Entry line
    local indent = current_section and "    " or "  "
    local name = entry.name
    local words_str = format_number(entry.words)
    local max_name_width = inner_width - #indent - #words_str - 2
    if #name > max_name_width then
      name = name:sub(1, max_name_width - 3) .. "..."
    end
    local entry_line = indent .. name .. string.rep(" ", inner_width - #indent - #name - #words_str + 2) .. words_str
    table.insert(lines, entry_line)
  end

  if #breakdown == 0 then
    table.insert(lines, center("No chapters yet", width))
  end

  table.insert(lines, "")

  return lines, highlights
end

function M.show()
  if not state.manuscript then
    vim.notify("No project loaded", vim.log.levels.WARN)
    return
  end

  local parent_win = vim.api.nvim_get_current_win()

  -- Calculate window size
  local width = math.min(60, math.floor(vim.o.columns * 0.6))
  local height = math.min(30, math.floor(vim.o.lines * 0.7))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Build content
  local lines, highlights = build_content(width)

  -- Adjust height to content
  height = math.min(height, #lines + 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("vimoire_stats")
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1] - 1, hl[2], hl[3])
  end

  -- Open float
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Stats ",
    title_pos = "center",
    footer = " [q] Close ",
    footer_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false

  -- Close keymaps
  local function close()
    vim.api.nvim_win_close(win, true)
    if vim.api.nvim_win_is_valid(parent_win) then
      vim.api.nvim_set_current_win(parent_win)
    end
  end

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  return buf, win
end

return M
