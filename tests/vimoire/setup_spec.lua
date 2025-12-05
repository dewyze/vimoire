local assert = require("luassert")
local helpers = require("tests.helpers")

describe("Setup", function()
  local setup = require("vimoire.setup")
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  after_each(function()
    helpers.reset_state()
  end)

  it("loads manuscript from manuscript.json argument", function()
    vim.fn.argv = function() return { fixture_path .. "/manuscript.json" } end
    assert.is_true(setup.load_manuscript())
    assert.is_not_nil(state.manuscript)
    assert.equals(state.manuscript.title, "The Unreliable Memoirs of Gerald the Sentient Toaster")
  end)

  it("loads manuscript from directory argument", function()
    vim.fn.argv = function() return { fixture_path } end
    assert.is_true(setup.load_manuscript())
    assert.is_not_nil(state.manuscript)
    assert.equals(state.manuscript.title, "The Unreliable Memoirs of Gerald the Sentient Toaster")
  end)

  it("fails when manuscript not found", function()
    vim.fn.argv = function() return { "tests/fixtures/nonexistent" } end
    assert.is_false(setup.load_manuscript())
    assert.is_nil(state.manuscript)
  end)
end)
