local assert = require("luassert")
local helpers = require("tests.helpers")

describe("State", function()
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  after_each(function()
    helpers.reset_state()
  end)

  it("loads manuscript and builds indexes", function()
    state:load(fixture_path)
    assert.is_not_nil(state.manuscript)
    assert.is_not_nil(state.entries)
    assert.is_not_nil(state.sections)
  end)

  it("creates entries map with correct count", function()
    state:load(fixture_path)
    -- 4 in Part 1 + 2 in Part 2 + 2 unsectioned = 8 entries
    assert.equals(8, vim.tbl_count(state.entries))
  end)

  it("creates sections with correct count", function()
    state:load(fixture_path)
    assert.equals(2, vim.tbl_count(state.sections))
  end)

  it("can rebuild indexes", function()
    state:load(fixture_path)
    local original_count = vim.tbl_count(state.entries)
    state:rebuild()
    assert.equals(original_count, vim.tbl_count(state.entries))
  end)

  it("sets chapter indices only for chapter entries", function()
    state:load(fixture_path)
    -- chap1a is 1st chapter (after page "Part One")
    local entry = state.entries["chap1a"]
    assert.equals("chapter", entry.kind)
    assert.equals(1, entry.chapter_index)
    assert.equals("1", entry:display_number())

    -- chap1b is 2nd chapter
    entry = state.entries["chap1b"]
    assert.equals(2, entry.chapter_index)
    assert.equals("2", entry:display_number())

    -- chap2a is 4th chapter (after 3 in Part 1)
    entry = state.entries["chap2a"]
    assert.equals(4, entry.chapter_index)
  end)

  it("returns nil display_number for pages", function()
    state:load(fixture_path)
    local page = state.entries["part1tp"]
    assert.equals("page", page.kind)
    assert.is_nil(page:display_number())
  end)

  it("loads flat manuscripts correctly", function()
    state:load("tests/fixtures/flat")
    assert.equals(3, vim.tbl_count(state.entries))
    assert.equals(0, vim.tbl_count(state.sections))

    local entry = state.entries["ch002"]
    assert.equals(2, entry.chapter_index)
    assert.equals("2", entry:display_number())
  end)

  describe("parent references", function()
    it("sets parent_items and parent_section for entries in sections", function()
      state:load(fixture_path)
      local entry = state.entries["chap1a"]
      local section = state.sections["p1x3q8"]

      assert.equals(section.items, entry.parent_items)
      assert.equals(section, entry.parent_section)
    end)

    it("sets parent_items to root and parent_section to nil for root entries", function()
      state:load(fixture_path)
      local entry = state.entries["intrlud"]

      assert.equals(state.manuscript.items, entry.parent_items)
      assert.is_nil(entry.parent_section)
    end)

    it("sets parent_items to root and parent_section to nil for sections", function()
      state:load(fixture_path)
      local section = state.sections["p1x3q8"]

      assert.equals(state.manuscript.items, section.parent_items)
      assert.is_nil(section.parent_section)
    end)
  end)
end)
