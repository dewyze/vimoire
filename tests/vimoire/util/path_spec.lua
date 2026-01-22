local assert = require("luassert")
local helpers = require("tests.helpers")

describe("util.path", function()
  local path = require("vimoire.util.path")
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  before_each(function()
    state:load(fixture_path)
  end)

  after_each(function()
    helpers.reset_state()
  end)

  describe("navigator_source", function()
    it("returns 'export' for files in exports directory", function()
      local filepath = state.manuscript.root .. "/exports/configs/default.yml"
      assert.equals("export", path.navigator_source(filepath))
    end)

    it("returns 'export' for nested export files", function()
      local filepath = state.manuscript.root .. "/exports/output/book.epub"
      assert.equals("export", path.navigator_source(filepath))
    end)

    it("returns 'manuscript' for entry files", function()
      local filepath = state.manuscript.root .. "/entries/chap1a/prose.md"
      assert.equals("manuscript", path.navigator_source(filepath))
    end)

    it("returns 'manuscript' for planning files", function()
      local filepath = state.manuscript.root .. "/planning/characters/gerald.md"
      assert.equals("manuscript", path.navigator_source(filepath))
    end)

    it("returns 'manuscript' for nil filepath", function()
      assert.equals("manuscript", path.navigator_source(nil))
    end)

    it("returns 'manuscript' when no manuscript loaded", function()
      helpers.reset_state()
      assert.equals("manuscript", path.navigator_source("/some/path"))
    end)
  end)
end)
