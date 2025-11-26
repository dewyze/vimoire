local assert = require("luassert")

describe("State", function()
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  after_each(function()
    state.manuscript = nil
    state.chapters = nil
    state.chapters_by_section = nil
    state.sections = nil
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
end)
