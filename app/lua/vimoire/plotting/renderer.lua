local M = {}

-- Box drawing characters
local BOX = {
  -- Outer border (solid)
  top_left = "┌",
  top_right = "┐",
  bottom_left = "└",
  bottom_right = "┘",
  horizontal = "─",
  vertical = "│",
  top_tee = "┬",
  bottom_tee = "┴",
  left_tee = "├",
  right_tee = "┤",
  -- Internal dividers (dotted/light)
  horizontal_light = "┄",
  vertical_light = "┆",
  cross_light = "┼",
  left_tee_light = "├",
  right_tee_light = "┤",
}

local MIN_COL_WIDTH = 8
local MAX_COL_WIDTH = 40

local function calculate_column_widths(board)
  local widths = {}

  for i, col in ipairs(board.columns) do
    local max_width = math.max(MIN_COL_WIDTH, vim.fn.strdisplaywidth(col.header))

    for _, row in ipairs(board.rows) do
      local cell = row.cells[col.id] or ""
      -- For multi-line cells, use the longest line
      for line in cell:gmatch("[^\n]+") do
        max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
      end
    end

    widths[i] = math.min(max_width, MAX_COL_WIDTH)
  end

  return widths
end

local function pad_or_truncate(text, width)
  local display_width = vim.fn.strdisplaywidth(text)
  if display_width > width then
    -- Truncate with ellipsis
    local result = ""
    local current_width = 0
    for char in text:gmatch(".") do
      local char_width = vim.fn.strdisplaywidth(char)
      if current_width + char_width + 1 > width then
        break
      end
      result = result .. char
      current_width = current_width + char_width
    end
    return result .. "…" .. string.rep(" ", width - current_width - 1)
  else
    return text .. string.rep(" ", width - display_width)
  end
end

local function render_horizontal_line(widths, left, middle, right, char)
  char = char or BOX.horizontal
  local parts = { left }
  for i, w in ipairs(widths) do
    table.insert(parts, string.rep(char, w + 2))
    if i < #widths then
      table.insert(parts, middle)
    end
  end
  table.insert(parts, right)
  return table.concat(parts)
end

-- Returns line string and byte positions for each cell
-- positions[col_idx] = { start_byte, end_byte }
local function render_content_line_with_positions(cells, widths, columns)
  local parts = {}
  local positions = {}
  local byte_offset = 0

  -- Leading vertical bar (solid outer edge)
  table.insert(parts, BOX.vertical)
  byte_offset = byte_offset + #BOX.vertical

  for i, col in ipairs(columns) do
    -- Space before content
    table.insert(parts, " ")
    byte_offset = byte_offset + 1

    local cell = cells[col.id] or ""
    local first_line = cell:match("^([^\n]*)") or ""
    local padded = pad_or_truncate(first_line, widths[i])

    -- Record cell position (byte offsets, 0-indexed for nvim API)
    positions[i] = {
      start_byte = byte_offset,
      end_byte = byte_offset + #padded,
    }

    table.insert(parts, padded)
    byte_offset = byte_offset + #padded

    -- Space after content
    table.insert(parts, " ")
    byte_offset = byte_offset + 1

    -- Vertical bar: light for internal, solid for outer edge
    local bar = (i < #columns) and BOX.vertical_light or BOX.vertical
    table.insert(parts, bar)
    byte_offset = byte_offset + #bar
  end

  return table.concat(parts), positions
end

local function render_content_line(cells, widths, columns)
  local line, _ = render_content_line_with_positions(cells, widths, columns)
  return line
end

-- Render the board and return:
-- { lines = {...}, cursor_pos = {row, col}, cell_positions = {...} }
-- cursor_pos is the screen position for the cursor
-- cell_positions maps {row_idx, col_idx} -> {start_col, end_col, line_num}
function M.render(board, cursor)
  cursor = cursor or { row = 0, col = 1 }

  local widths = calculate_column_widths(board)
  local lines = {}
  local cell_positions = {}

  -- Title line
  table.insert(lines, " " .. board.name)
  table.insert(lines, "")

  -- Top border
  table.insert(lines, render_horizontal_line(widths, BOX.top_left, BOX.top_tee, BOX.top_right))

  -- Header row (row 0 in cursor coordinates)
  local header_cells = {}
  for _, col in ipairs(board.columns) do
    header_cells[col.id] = col.header
  end
  local header_line_num = #lines + 1
  local header_line, header_positions = render_content_line_with_positions(header_cells, widths, board.columns)
  table.insert(lines, header_line)

  -- Store header positions as row 0
  cell_positions[0] = {}
  for col_idx, pos in ipairs(header_positions) do
    cell_positions[0][col_idx] = {
      start_byte = pos.start_byte,
      end_byte = pos.end_byte,
      line = header_line_num,
    }
  end

  -- Header separator (light)
  table.insert(lines, render_horizontal_line(widths, BOX.left_tee_light, BOX.cross_light, BOX.right_tee_light, BOX.horizontal_light))

  -- Data rows
  for row_idx, row in ipairs(board.rows) do
    local line_num = #lines + 1
    local line, positions = render_content_line_with_positions(row.cells, widths, board.columns)

    cell_positions[row_idx] = {}
    for col_idx, pos in ipairs(positions) do
      cell_positions[row_idx][col_idx] = {
        start_byte = pos.start_byte,
        end_byte = pos.end_byte,
        line = line_num,
      }
    end

    table.insert(lines, line)

    -- Row separator (light, except after last row)
    if row_idx < #board.rows then
      table.insert(lines, render_horizontal_line(widths, BOX.left_tee_light, BOX.cross_light, BOX.right_tee_light, BOX.horizontal_light))
    end
  end

  -- Bottom border
  table.insert(lines, render_horizontal_line(widths, BOX.bottom_left, BOX.bottom_tee, BOX.bottom_right))

  -- Calculate cursor position (for vim cursor, 1-indexed line, 0-indexed byte col)
  local cursor_line = 0
  local cursor_col = 0
  if cell_positions[cursor.row] and cell_positions[cursor.row][cursor.col] then
    local pos = cell_positions[cursor.row][cursor.col]
    cursor_line = pos.line
    cursor_col = pos.start_byte  -- Already 0-indexed byte offset
  end

  return {
    lines = lines,
    cursor_line = cursor_line,
    cursor_col = cursor_col,
    cell_positions = cell_positions,
    widths = widths,
  }
end

return M
