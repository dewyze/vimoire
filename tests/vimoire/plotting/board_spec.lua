local helpers = require("tests.helpers")
local Board = require("vimoire.plotting.board")
local persistence = require("vimoire.plotting.persistence")

describe("Board", function()
  local root

  before_each(function()
    root = helpers.temp_dir()
    vim.fn.mkdir(root .. "/plotting", "p")
  end)

  after_each(function()
    helpers.cleanup()
  end)

  describe("new", function()
    it("creates board with id, name, path", function()
      local board = Board.new("abc123", "Test Board", root .. "/plotting/abc123.json")

      assert.equal("abc123", board.id)
      assert.equal("Test Board", board.name)
      assert.equal("plotting_board", board.kind)
      assert.equal(root .. "/plotting/abc123.json", board.path)
    end)

    it("initializes empty columns and rows", function()
      local board = Board.new("abc123", "Test Board", root .. "/plotting/abc123.json")

      assert.same({}, board.columns)
      assert.same({}, board.rows)
    end)
  end)

  describe("load", function()
    it("loads board from JSON file", function()
      local path = root .. "/plotting/test.json"
      persistence.write(path, {
        id = "xyz789",
        name = "Loaded Board",
        columns = { { id = "col1", header = "Plot" } },
        rows = { { id = "row1", cells = { col1 = "Chapter 1" } } },
      })

      local board = Board.load(path)

      assert.equal("xyz789", board.id)
      assert.equal("Loaded Board", board.name)
      assert.equal(1, #board.columns)
      assert.equal(1, #board.rows)
      assert.equal("Chapter 1", board.rows[1].cells.col1)
    end)

    it("returns nil for missing file", function()
      local board = Board.load(root .. "/plotting/missing.json")
      assert.is_nil(board)
    end)
  end)

  describe("create", function()
    it("creates board with default structure", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = {}

      local board = Board.create(state, "New Board", parent_items, 1)

      assert.is_not_nil(board)
      assert.equal("New Board", board.name)
      assert.equal(1, #board.columns)
      assert.equal(1, #board.rows)
    end)

    it("registers in state.items", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = {}

      local board = Board.create(state, "New Board", parent_items, 1)

      assert.equal(board, state.items[board.id])
    end)

    it("adds to parent_items at index", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = { { id = "existing" } }

      local board = Board.create(state, "New Board", parent_items, 1)

      assert.equal(2, #parent_items)
      assert.equal(board.id, parent_items[1].id)
    end)

    it("persists to disk", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = {}

      local board = Board.create(state, "New Board", parent_items, 1)

      assert.equal(1, vim.fn.filereadable(board.path))
    end)
  end)

  describe("cell operations", function()
    local board

    before_each(function()
      board = Board.new("test", "Test", root .. "/plotting/test.json")
      board.columns = { { id = "col1", header = "A" }, { id = "col2", header = "B" } }
      board.rows = {
        { id = "row1", cells = { col1 = "R1C1", col2 = "R1C2" } },
        { id = "row2", cells = { col1 = "R2C1", col2 = "R2C2" } },
      }
    end)

    it("get_cell returns cell content", function()
      assert.equal("R1C1", board:get_cell("row1", "col1"))
      assert.equal("R2C2", board:get_cell("row2", "col2"))
    end)

    it("get_cell returns empty string for missing cell", function()
      assert.equal("", board:get_cell("row1", "missing"))
      assert.equal("", board:get_cell("missing", "col1"))
    end)

    it("set_cell updates cell content", function()
      board:set_cell("row1", "col1", "Updated")
      assert.equal("Updated", board.rows[1].cells.col1)
    end)
  end)

  describe("row operations", function()
    local board

    before_each(function()
      board = Board.new("test", "Test", root .. "/plotting/test.json")
      board.columns = { { id = "col1", header = "A" } }
      board.rows = { { id = "row1", cells = { col1 = "Cell" } } }
    end)

    it("add_row inserts row after index", function()
      local row_id, index = board:add_row(1)

      assert.equal(2, #board.rows)
      assert.equal(2, index)
      assert.equal(row_id, board.rows[2].id)
    end)

    it("add_row initializes empty cells", function()
      board:add_row(1)

      assert.equal("", board.rows[2].cells.col1)
    end)

    it("delete_row removes row", function()
      board:add_row(1)
      local ok = board:delete_row(2)

      assert.is_true(ok)
      assert.equal(1, #board.rows)
    end)

    it("delete_row fails on last row", function()
      local ok, err = board:delete_row(1)

      assert.is_false(ok)
      assert.is_not_nil(err)
    end)
  end)

  describe("column operations", function()
    local board

    before_each(function()
      board = Board.new("test", "Test", root .. "/plotting/test.json")
      board.columns = { { id = "col1", header = "A" } }
      board.rows = { { id = "row1", cells = { col1 = "Cell" } } }
    end)

    it("add_column inserts column after index", function()
      local col_id, index = board:add_column(1)

      assert.equal(2, #board.columns)
      assert.equal(2, index)
      assert.equal(col_id, board.columns[2].id)
    end)

    it("add_column adds empty cells to rows", function()
      local col_id = board:add_column(1)

      assert.equal("", board.rows[1].cells[col_id])
    end)

    it("delete_column removes column", function()
      board:add_column(1)
      local ok = board:delete_column(2)

      assert.is_true(ok)
      assert.equal(1, #board.columns)
    end)

    it("delete_column removes cells from rows", function()
      local col_id = board:add_column(1)
      board:delete_column(2)

      assert.is_nil(board.rows[1].cells[col_id])
    end)

    it("delete_column fails on last column", function()
      local ok, err = board:delete_column(1)

      assert.is_false(ok)
      assert.is_not_nil(err)
    end)
  end)

  describe("interface", function()
    it("display_name returns name", function()
      local board = Board.new("test", "My Board", root .. "/test.json")
      assert.equal("My Board", board:display_name())
    end)

    it("text_path returns nil", function()
      local board = Board.new("test", "My Board", root .. "/test.json")
      assert.is_nil(board:text_path())
    end)

    it("category returns plotting", function()
      local board = Board.new("test", "My Board", root .. "/test.json")
      assert.equal("plotting", board:category())
    end)
  end)

  describe("destroy", function()
    it("deletes file from disk", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = {}
      local board = Board.create(state, "Test", parent_items, 1)

      board:destroy(state)

      assert.equal(0, vim.fn.filereadable(board.path))
    end)

    it("removes from state.items", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = {}
      local board = Board.create(state, "Test", parent_items, 1)
      local id = board.id

      board:destroy(state)

      assert.is_nil(state.items[id])
    end)

    it("removes from parent_items", function()
      local state = {
        items = {},
        manuscript = { root = root },
      }
      local parent_items = {}
      local board = Board.create(state, "Test", parent_items, 1)

      board:destroy(state)

      assert.equal(0, #parent_items)
    end)
  end)
end)
