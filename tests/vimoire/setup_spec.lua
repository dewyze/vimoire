local assert = require("luassert")
local helpers = require("tests.helpers")

describe("Setup", function()
  local setup = require("vimoire.setup")
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  after_each(function()
    helpers.reset_state()
  end)

  describe("on_manuscript_loaded", function()
    it("sets up statusline", function()
      state:load(fixture_path)
      setup.on_manuscript_loaded()
      -- Statusline is now window-local and uses highlight groups
      assert.is_not_nil(vim.wo.statusline)
      assert.matches("%%#", vim.wo.statusline)
    end)

    it("adds to recent projects", function()
      local recent = require("vimoire.core.recent")
      state:load(fixture_path)
      setup.on_manuscript_loaded()
      local projects = recent.list()
      assert.is_true(#projects > 0)
    end)
  end)
end)
