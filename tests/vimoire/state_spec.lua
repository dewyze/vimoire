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
    assert.is_not_nil(state.chapters)
    assert.is_not_nil(state.chapters_by_section)
    assert.is_not_nil(state.sections)
  end)

  it("creates chapters map with correct count", function()
    state:load(fixture_path)
    assert.equals(vim.tbl_count(state.chapters), 5)
  end)

  it("creates sections with correct count", function()
    state:load(fixture_path)
    assert.equals(vim.tbl_count(state.sections), 2)
  end)

  it("indexes chapters by section", function()
    state:load(fixture_path)
    local section_chapters = state.chapters_by_section["p1x3q8"]
    assert.equals(#section_chapters, 3)
    assert.equals(section_chapters[1].title, "The Day I Became Sentient")
  end)

  it("can rebuild indexes", function()
    state:load(fixture_path)
    local original_count = vim.tbl_count(state.chapters)
    state:rebuild()
    assert.equals(vim.tbl_count(state.chapters), original_count)
  end)

  it("sets section index on sections", function()
    state:load(fixture_path)
    assert.equals(state.sections["p1x3q8"].index, 1)
    assert.equals(state.sections["p2y5r4"].index, 2)
  end)

  it("sets chapter indices for multi-section manuscripts", function()
    state:load(fixture_path)
    local chapter = state.chapters["chap1b"]
    assert.equals(chapter.section_index, 1)
    assert.equals(chapter.chapter_index, 2)
    assert.equals(chapter:display_number(), "1.2")
  end)

  it("sets nil section_index for unsectioned manuscripts", function()
    state:load("tests/fixtures/flat")
    local chapter = state.chapters["ch002"]
    assert.is_nil(chapter.section_index)
    assert.equals(chapter.chapter_index, 2)
    assert.equals(chapter:display_number(), "2")
  end)

  it("builds chapter_groups for sectioned manuscripts", function()
    state:load(fixture_path)
    assert.equals(#state.chapter_groups, 2)

    local group1 = state.chapter_groups[1]
    assert.equals(group1.section.id, "p1x3q8")
    assert.equals(#group1.chapters, 3)

    local group2 = state.chapter_groups[2]
    assert.equals(group2.section.id, "p2y5r4")
    assert.equals(#group2.chapters, 2)
  end)

  it("builds chapter_groups for flat manuscripts", function()
    state:load("tests/fixtures/flat")
    assert.equals(#state.chapter_groups, 1)

    local group = state.chapter_groups[1]
    assert.is_nil(group.section)
    assert.equals(#group.chapters, 2)
    assert.equals(group.chapters[1].title, "The First Sock")
  end)
end)
