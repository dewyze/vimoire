local M = {}

-- Cursor state per buffer: { row = 1, col = 1 }
M.cursors = {}

function M.init_cursor(buf)
  -- row = 0 is header, row >= 1 is data
  M.cursors[buf] = { row = 0, col = 1 }
end

function M.get_cursor(buf)
  return M.cursors[buf] or { row = 0, col = 1 }
end

function M.clear_cursor(buf)
  M.cursors[buf] = nil
end

local directions = {
  left = function(cursor, _, num_cols)
    cursor.col = cursor.col > 1 and cursor.col - 1 or num_cols
  end,
  right = function(cursor, _, num_cols)
    cursor.col = cursor.col < num_cols and cursor.col + 1 or 1
  end,
  up = function(cursor, num_rows)
    -- row 0 is header, wraps to last data row
    cursor.row = cursor.row > 0 and cursor.row - 1 or num_rows
  end,
  down = function(cursor, num_rows)
    -- row 0 is header, num_rows is last data row
    cursor.row = cursor.row < num_rows and cursor.row + 1 or 0
  end,
  first_col = function(cursor)
    cursor.col = 1
  end,
  last_col = function(cursor, _, num_cols)
    cursor.col = num_cols
  end,
  first_row = function(cursor)
    cursor.row = 0
  end,
  last_row = function(cursor, num_rows)
    cursor.row = num_rows
  end,
}

function M.move(board, buf, direction)
  local cursor = M.get_cursor(buf)
  local handler = directions[direction]
  if handler then
    handler(cursor, #board.rows, #board.columns)
  end
  M.cursors[buf] = cursor

  local buffer = require("vimoire.plotting.buffer")
  buffer.render(board, buf)
end

function M.edit_cell(board, buf)
  local cursor = M.get_cursor(buf)
  local col = board.columns[cursor.col]

  if not col then
    return
  end

  local editor = require("vimoire.plotting.editor")

  -- Row 0 is header
  if cursor.row == 0 then
    editor.open({
      title = "Edit Header",
      content = col.header or "",
      on_save = function(new_content)
        board:set_column_header(cursor.col, new_content)
        local buffer = require("vimoire.plotting.buffer")
        buffer.render(board, buf)
      end,
    })
    return
  end

  local row = board.rows[cursor.row]
  if not row then
    return
  end

  editor.open({
    title = "Edit Cell",
    content = row.cells[col.id] or "",
    on_save = function(new_content)
      board:set_cell(row.id, col.id, new_content)
      local buffer = require("vimoire.plotting.buffer")
      buffer.render(board, buf)
    end,
  })
end

function M.view_cell(board, buf)
  local cursor = M.get_cursor(buf)
  local col = board.columns[cursor.col]

  if not col then
    return
  end

  local editor = require("vimoire.plotting.editor")

  -- Row 0 is header
  if cursor.row == 0 then
    editor.view({
      title = col.header or "(empty header)",
      content = col.header or "",
      on_edit = function() M.edit_cell(board, buf) end,
    })
    return
  end

  local row = board.rows[cursor.row]
  if not row then
    return
  end

  editor.view({
    title = "Cell",
    content = row.cells[col.id] or "",
    on_edit = function() M.edit_cell(board, buf) end,
  })
end

function M.add_row(board, buf, position)
  local cursor = M.get_cursor(buf)

  -- If on header row (0), insert as first data row
  local after_index
  if cursor.row == 0 then
    after_index = 0  -- Insert at beginning of data rows
  elseif position == "below" then
    after_index = cursor.row
  else
    after_index = cursor.row - 1
  end

  local _, new_index = board:add_row(after_index)

  -- Move cursor to new row
  cursor.row = new_index
  M.cursors[buf] = cursor

  local buffer = require("vimoire.plotting.buffer")
  buffer.render(board, buf)
end

function M.add_column(board, buf, position)
  local cursor = M.get_cursor(buf)

  local after_index
  if position == "after" then
    after_index = cursor.col
  elseif position == "before" then
    after_index = cursor.col - 1
  elseif position == "at_start" then
    after_index = 0
  elseif position == "at_end" then
    after_index = #board.columns
  end

  local _, new_index = board:add_column(after_index)

  -- Move cursor to new column
  cursor.col = new_index
  M.cursors[buf] = cursor

  local buffer = require("vimoire.plotting.buffer")
  buffer.render(board, buf)
end

function M.delete_row(board, buf)
  local cursor = M.get_cursor(buf)

  -- Can't delete header row
  if cursor.row == 0 then
    vim.notify("Cannot delete header row", vim.log.levels.WARN)
    return
  end

  local ok, err = board:delete_row(cursor.row)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Adjust cursor if needed
  if cursor.row > #board.rows then
    cursor.row = #board.rows
  end
  M.cursors[buf] = cursor

  local buffer = require("vimoire.plotting.buffer")
  buffer.render(board, buf)
end

function M.delete_column(board, buf)
  local cursor = M.get_cursor(buf)

  local ok, err = board:delete_column(cursor.col)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Adjust cursor if needed
  if cursor.col > #board.columns then
    cursor.col = #board.columns
  end
  M.cursors[buf] = cursor

  local buffer = require("vimoire.plotting.buffer")
  buffer.render(board, buf)
end

return M
