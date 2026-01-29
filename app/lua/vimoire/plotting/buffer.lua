local renderer = require("vimoire.plotting.renderer")

local M = {}

-- Track open buffers by board id
M.buffers = {}

local function setup_keymaps(buf, board)
  local opts = { buffer = buf, nowait = true, silent = true }
  local nav = require("vimoire.plotting.navigation")

  -- Navigation
  vim.keymap.set("n", "h", function() nav.move(board, buf, "left") end, opts)
  vim.keymap.set("n", "j", function() nav.move(board, buf, "down") end, opts)
  vim.keymap.set("n", "k", function() nav.move(board, buf, "up") end, opts)
  vim.keymap.set("n", "l", function() nav.move(board, buf, "right") end, opts)
  vim.keymap.set("n", "b", function() nav.move(board, buf, "left") end, opts)
  vim.keymap.set("n", "w", function() nav.move(board, buf, "right") end, opts)

  -- First/last in row
  vim.keymap.set("n", "^", function() nav.move(board, buf, "first_col") end, opts)
  vim.keymap.set("n", "1", function() nav.move(board, buf, "first_col") end, opts)
  vim.keymap.set("n", "$", function() nav.move(board, buf, "last_col") end, opts)
  vim.keymap.set("n", "0", function() nav.move(board, buf, "last_col") end, opts)

  -- First/last row
  vim.keymap.set("n", "gg", function() nav.move(board, buf, "first_row") end, opts)
  vim.keymap.set("n", "G", function() nav.move(board, buf, "last_row") end, opts)

  -- Editing
  vim.keymap.set("n", "<CR>", function() nav.edit_cell(board, buf) end, opts)
  vim.keymap.set("n", "e", function() nav.edit_cell(board, buf) end, opts)
  vim.keymap.set("n", "a", function() nav.edit_cell(board, buf) end, opts)
  vim.keymap.set("n", "i", function() nav.edit_cell(board, buf) end, opts)

  -- View cell (read-only)
  vim.keymap.set("n", "K", function() nav.view_cell(board, buf) end, opts)

  -- Add rows/columns
  vim.keymap.set("n", "o", function() nav.add_row(board, buf, "below") end, opts)
  vim.keymap.set("n", "O", function() nav.add_row(board, buf, "above") end, opts)
  vim.keymap.set("n", "I", function() nav.add_column(board, buf, "at_start") end, opts)
  vim.keymap.set("n", "A", function() nav.add_column(board, buf, "at_end") end, opts)

  -- Delete
  vim.keymap.set("n", "dd", function() nav.delete_row(board, buf) end, opts)
  vim.keymap.set("n", "dc", function() nav.delete_column(board, buf) end, opts)

  vim.keymap.set("n", "q", function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end, opts)
end

function M.render(board, buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local nav = require("vimoire.plotting.navigation")
  local cursor = nav.get_cursor(buf)
  local result = renderer.render(board, cursor)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result.lines)
  vim.bo[buf].modifiable = false

  -- Apply highlights
  M.apply_highlights(buf, board, cursor, result)

  -- Position cursor
  if result.cursor_line > 0 then
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      -- cursor_line is 1-indexed, cursor_col is already 0-indexed byte offset
      vim.api.nvim_win_set_cursor(win, { result.cursor_line, result.cursor_col })
    end
  end
end

local function is_border_line(line)
  -- Border lines contain only box-drawing characters and spaces
  return line:match("^[─┄│┆┌┐└┘┬┴├┤┼ ]+$") ~= nil
end

function M.apply_highlights(buf, board, cursor, result)
  local ns = vim.api.nvim_create_namespace("vimoire_plotting")
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  -- Highlight title
  vim.api.nvim_buf_add_highlight(buf, ns, "Title", 0, 0, -1)

  -- Highlight borders and header
  for i, line in ipairs(result.lines) do
    local line_idx = i - 1 -- 0-indexed for nvim API
    if is_border_line(line) then
      vim.api.nvim_buf_add_highlight(buf, ns, "VimoirePlottingBorder", line_idx, 0, -1)
    end
  end

  -- Highlight header cells
  if result.cell_positions[0] then
    for _, pos in pairs(result.cell_positions[0]) do
      vim.api.nvim_buf_add_highlight(buf, ns, "VimoirePlottingHeader", pos.line - 1, pos.start_byte, pos.end_byte)
    end
  end

  -- Highlight current cell (on top of other highlights)
  if result.cell_positions[cursor.row] and result.cell_positions[cursor.row][cursor.col] then
    local pos = result.cell_positions[cursor.row][cursor.col]
    vim.api.nvim_buf_add_highlight(buf, ns, "CurSearch", pos.line - 1, pos.start_byte, pos.end_byte)
  end
end

-- Called from BufReadCmd - buf is already created by vim
function M.setup_buffer(buf, board)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "vimoire_plotting"

  -- Window options for proper display
  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    vim.wo[win].wrap = false
    vim.wo[win].cursorline = false
  end

  -- Store board reference
  M.buffers[buf] = board

  -- Initialize cursor state
  local nav = require("vimoire.plotting.navigation")
  nav.init_cursor(buf)

  setup_keymaps(buf, board)

  -- Initial render
  M.render(board, buf)

  -- Clean up on buffer delete
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      M.buffers[buf] = nil
      nav.clear_cursor(buf)
    end,
  })
end

return M
