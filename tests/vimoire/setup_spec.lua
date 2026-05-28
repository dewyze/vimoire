local assert = require("luassert")
local helpers = require("tests.helpers")

describe("Setup", function()
  local setup = require("vimoire.setup")
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  before_each(function()
    helpers.setup_test_preferences()
  end)

  after_each(function()
    helpers.reset_state()
    helpers.reset_preferences()
  end)

  describe("on_manuscript_loaded", function()
    it("sets up statusline on vimoire buffers", function()
      -- Statusline is whitelisted to vimoire buffers, so it only applies the
      -- highlighted statusline when the current buffer is vimoire prose/markdown.
      vim.bo.filetype = "vimoire_prose"
      state:load(fixture_path)
      setup.on_manuscript_loaded()
      assert.is_not_nil(vim.wo.statusline)
      assert.matches("%%#", vim.wo.statusline)
    end)

    it("adds to recent projects", function()
      local recent = require("vimoire.recent")
      state:load(fixture_path)
      setup.on_manuscript_loaded()
      local projects = recent.list()
      assert.is_true(#projects > 0)
    end)
  end)
end)
