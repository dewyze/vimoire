local renderer = require("vimoire.plotting.renderer")

describe("renderer", function()
  local board

  before_each(function()
    board = {
      id = "test",
      name = "Test Board",
      columns = {
        { id = "col1", header = "Chapter" },
        { id = "col2", header = "Plot" },
      },
      rows = {
        { id = "row1", cells = { col1 = "Ch 1", col2 = "Hero arrives" } },
        { id = "row2", cells = { col1 = "Ch 2", col2 = "Conflict begins" } },
      },
    }
  end)

  describe("render", function()
    it("returns lines array", function()
      local result = renderer.render(board)
      assert.is_table(result.lines)
      assert.is_true(#result.lines > 0)
    end)

    it("includes board name in title", function()
      local result = renderer.render(board)
      assert.matches("Test Board", result.lines[1])
    end)

    it("includes column headers", function()
      local result = renderer.render(board)
      local found_chapter = false
      local found_plot = false
      for _, line in ipairs(result.lines) do
        if line:match("Chapter") then found_chapter = true end
        if line:match("Plot") then found_plot = true end
      end
      assert.is_true(found_chapter)
      assert.is_true(found_plot)
    end)

    it("includes cell content", function()
      local result = renderer.render(board)
      local found_hero = false
      local found_conflict = false
      for _, line in ipairs(result.lines) do
        if line:match("Hero arrives") then found_hero = true end
        if line:match("Conflict begins") then found_conflict = true end
      end
      assert.is_true(found_hero)
      assert.is_true(found_conflict)
    end)

    it("includes box characters", function()
      local result = renderer.render(board)
      local has_box = false
      for _, line in ipairs(result.lines) do
        if line:match("[┌┐└┘│─┬┴├┤┼]") then
          has_box = true
          break
        end
      end
      assert.is_true(has_box)
    end)

    it("returns cursor position for default cursor", function()
      local result = renderer.render(board, { row = 1, col = 1 })
      assert.is_number(result.cursor_line)
      assert.is_number(result.cursor_col)
      assert.is_true(result.cursor_line > 0)
    end)

    it("returns cell_positions map", function()
      local result = renderer.render(board)
      assert.is_table(result.cell_positions)
      assert.is_table(result.cell_positions[1])
      assert.is_table(result.cell_positions[1][1])
    end)

    it("cell_positions contains start_byte, end_byte, line", function()
      local result = renderer.render(board)
      local pos = result.cell_positions[1][1]
      assert.is_number(pos.start_byte)
      assert.is_number(pos.end_byte)
      assert.is_number(pos.line)
    end)
  end)

  describe("render with empty cells", function()
    it("handles empty cell content", function()
      board.rows[1].cells.col2 = ""
      local result = renderer.render(board)
      assert.is_table(result.lines)
    end)

    it("handles nil cell content", function()
      board.rows[1].cells.col2 = nil
      local result = renderer.render(board)
      assert.is_table(result.lines)
    end)
  end)

  describe("render with long content", function()
    it("truncates long cell content", function()
      board.rows[1].cells.col1 = "This is a very long chapter title that should be truncated"
      local result = renderer.render(board)
      -- Should not error and should produce output
      assert.is_table(result.lines)
    end)
  end)
end)
