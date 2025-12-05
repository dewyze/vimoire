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
    assert.is_not_nil(state.items)
  end)

  it("creates items map with entries, sections, folders, and planning items", function()
    state:load(fixture_path)
    -- 5 folders + 8 entries + 2 sections + 8 planning items = 23
    assert.equals(23, vim.tbl_count(state.items))
  end)

  it("can rebuild indexes", function()
    state:load(fixture_path)
    local original_count = vim.tbl_count(state.items)
    state:rebuild()
    assert.equals(original_count, vim.tbl_count(state.items))
  end)

  it("sets chapter indices only for chapter entries", function()
    state:load(fixture_path)
    -- chap1a is 1st chapter (after page "Part One")
    local entry = state.items["chap1a"]
    assert.equals("chapter", entry.kind)
    assert.equals(1, entry.chapter_index)
    assert.equals("1", entry:display_number())

    -- chap1b is 2nd chapter
    entry = state.items["chap1b"]
    assert.equals(2, entry.chapter_index)
    assert.equals("2", entry:display_number())

    -- chap2a is 4th chapter (after 3 in Part 1)
    entry = state.items["chap2a"]
    assert.equals(4, entry.chapter_index)
  end)

  it("returns nil display_number for pages", function()
    state:load(fixture_path)
    local page = state.items["part1tp"]
    assert.equals("page", page.kind)
    assert.is_nil(page:display_number())
  end)

  it("loads flat manuscripts correctly", function()
    state:load("tests/fixtures/flat")
    -- 5 folders + 3 entries + 0 sections + 0 planning = 8
    assert.equals(8, vim.tbl_count(state.items))

    local entry = state.items["ch002"]
    assert.equals(2, entry.chapter_index)
    assert.equals("2", entry:display_number())
  end)

  it("indexes immutable folders", function()
    state:load(fixture_path)
    assert.is_not_nil(state.items["manuscript"])
    assert.is_not_nil(state.items["planning"])
    assert.is_not_nil(state.items["characters"])
    assert.is_not_nil(state.items["settings"])
    assert.is_not_nil(state.items["reference"])

    assert.is_true(state.items["manuscript"].immutable)
    assert.is_true(state.items["planning"].immutable)
  end)

  it("indexes planning items", function()
    state:load(fixture_path)
    local gerald = state.items["char1"]
    assert.is_not_nil(gerald)
    assert.equals("Gerald", gerald.name)
    assert.equals("characters", gerald.type)
  end)

  describe("parent references", function()
    it("sets parent_items and parent_section for entries in sections", function()
      state:load(fixture_path)
      local entry = state.items["chap1a"]
      local section = state.items["p1x3q8"]

      assert.equals(section.items, entry.parent_items)
      assert.equals(section, entry.parent_section)
    end)

    it("sets parent_items to root and parent_section to nil for root entries", function()
      state:load(fixture_path)
      local entry = state.items["intrlud"]

      assert.equals(state.manuscript.items, entry.parent_items)
      assert.is_nil(entry.parent_section)
    end)

    it("sets parent_items to root and parent_section to nil for sections", function()
      state:load(fixture_path)
      local section = state.items["p1x3q8"]

      assert.equals(state.manuscript.items, section.parent_items)
      assert.is_nil(section.parent_section)
    end)
  end)
end)
