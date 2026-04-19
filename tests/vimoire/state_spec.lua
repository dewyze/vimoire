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

    local by_kind = {}
    for _, item in pairs(state.items) do
      by_kind[item.kind] = (by_kind[item.kind] or 0) + 1
    end

    assert.same({
      -- Manuscript content
      book = 1,
      chapter = 6,
      page = 3,
      section = 2,
      -- Planning
      planning_item = 8,
      subfolder = 1,
      -- Exports scanned from disk
      export_file = 5,
      -- Synthetic folders (one per kind)
      manuscript = 1,
      planning = 1,
      characters = 1,
      settings = 1,
      reference = 1,
      orphaned_notes = 1,
      plotting = 1,
      export = 1,
      export_folder = 3,
    }, by_kind)
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

    local by_kind = {}
    for _, item in pairs(state.items) do
      by_kind[item.kind] = (by_kind[item.kind] or 0) + 1
    end

    assert.same({
      book = 1,
      chapter = 2,
      page = 1,
      manuscript = 1,
      planning = 1,
      characters = 1,
      settings = 1,
      reference = 1,
      orphaned_notes = 1,
      plotting = 1,
      export = 1,
      export_folder = 3,
    }, by_kind)

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
    assert.equals("planning_item", gerald.kind)
  end)

  describe("view attributes", function()
    local view = require("vimoire.view")

    it("resolves icon for manuscript folder via view module", function()
      assert.is_not_nil(view.icon_for("manuscript"))
    end)

    it("resolves highlight for chapter via view module", function()
      assert.equals("VimoireChapter", view.highlight_for("chapter"))
    end)

    it("applies add_options to section", function()
      state:load(fixture_path)
      local section = state.items["p1x3q8"]
      assert.is_table(section:add_options())
      assert.is_true(#section:add_options() > 0)
    end)

    it("marks folders as immutable", function()
      state:load(fixture_path)
      assert.is_true(state.items["manuscript"].immutable)
      assert.is_true(state.items["characters"].immutable)
    end)

    it("does not mark entries as immutable", function()
      state:load(fixture_path)
      local chapter = state.items["chap1a"]
      assert.is_nil(chapter.immutable)
    end)
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
