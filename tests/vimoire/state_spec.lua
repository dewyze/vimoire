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
    assert.is_not_nil(state.entries_by_section)
    assert.is_not_nil(state.sections)
  end)

  it("creates entries map with correct count", function()
    state:load(fixture_path)
    assert.equals(vim.tbl_count(state.entries), 8)
  end)

  it("creates sections with correct count", function()
    state:load(fixture_path)
    assert.equals(vim.tbl_count(state.sections), 2)
  end)

  it("indexes entries by section", function()
    state:load(fixture_path)
    local section_entries = state.entries_by_section["p1x3q8"]
    assert.equals(#section_entries, 4)
    assert.equals(section_entries[1].title, "Part One")
  end)

  it("can rebuild indexes", function()
    state:load(fixture_path)
    local original_count = vim.tbl_count(state.entries)
    state:rebuild()
    assert.equals(vim.tbl_count(state.entries), original_count)
  end)

  it("sets section index on sections", function()
    state:load(fixture_path)
    assert.equals(state.sections["p1x3q8"].index, 1)
    assert.equals(state.sections["p2y5r4"].index, 2)
  end)

  it("sets chapter indices only for chapter entries", function()
    state:load(fixture_path)
    local entry = state.entries["chap1b"]
    assert.equals(entry.kind, "chapter")
    assert.equals(entry.section_index, 1)
    assert.equals(entry.chapter_index, 2)
    assert.equals(entry:display_number(), "1.2")
  end)

  it("sets nil section_index for unsectioned manuscripts", function()
    state:load("tests/fixtures/flat")
    local entry = state.entries["ch002"]
    assert.is_nil(entry.section_index)
    assert.equals(entry.chapter_index, 2)
    assert.equals(entry:display_number(), "2")
  end)

  it("builds entry_groups for sectioned manuscripts", function()
    state:load(fixture_path)
    assert.equals(#state.entry_groups, 3)

    local group1 = state.entry_groups[1]
    assert.equals(group1.section.id, "p1x3q8")
    assert.equals(#group1.entries, 4)

    local group2 = state.entry_groups[2]
    assert.equals(group2.section.id, "p2y5r4")
    assert.equals(#group2.entries, 2)

    local group3 = state.entry_groups[3]
    assert.is_nil(group3.section)
    assert.equals(#group3.entries, 2)
  end)

  it("builds entry_groups for flat manuscripts", function()
    state:load("tests/fixtures/flat")
    assert.equals(#state.entry_groups, 1)

    local group = state.entry_groups[1]
    assert.is_nil(group.section)
    assert.equals(#group.entries, 3)
    assert.equals(group.entries[1].title, "The First Sock")
  end)
end)
