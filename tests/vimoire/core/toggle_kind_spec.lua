local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("item:toggle", function()
  local fixture_path = "tests/fixtures/standard"
  local temp_dir

  before_each(function()
    temp_dir = helpers.temp_copy(fixture_path)
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  it("toggles chapter to page", function()
    local chapter = state.items["chap1a"]
    assert.equals("chapter", chapter.kind)

    local ok = chapter:toggle(state)

    assert.is_true(ok)
    assert.equals("page", state.items["chap1a"].kind)
  end)

  it("toggles page to chapter", function()
    local page = state.items["intrlud"]
    assert.equals("page", page.kind)

    local ok = page:toggle(state)

    assert.is_true(ok)
    assert.equals("chapter", state.items["intrlud"].kind)
  end)

  it("reindexes chapters after toggle", function()
    -- chap1a is chapter 1, chap1b is chapter 2
    assert.equals(1, state.items["chap1a"].chapter_index)
    assert.equals(2, state.items["chap1b"].chapter_index)

    -- Toggle chap1a to page
    state.items["chap1a"]:toggle(state)

    -- Now chap1b should be chapter 1
    assert.is_nil(state.items["chap1a"].chapter_index)
    assert.equals(1, state.items["chap1b"].chapter_index)
  end)

  it("persists to manuscript", function()
    local chapter = state.items["chap1a"]

    chapter:toggle(state)

    -- Reload and verify
    state:load(temp_dir)
    assert.equals("page", state.items["chap1a"].kind)
  end)

  it("returns false for sections", function()
    local section = state.items["p1x3q8"]

    local ok, err = section:toggle(state)

    assert.is_false(ok)
    assert.equals("Can only toggle chapters and pages", err)
  end)

  it("returns false for immutable items", function()
    local manuscript = state.items["manuscript"]

    local ok, err = manuscript:toggle(state)

    assert.is_false(ok)
    assert.equals("Can only toggle chapters and pages", err)
  end)
end)
