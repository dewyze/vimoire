local assert = require("luassert")

describe("Section", function()
  local Section = require("vimoire.core.section")
  local state = require("vimoire.state")
  local fixture_path = "tests/fixtures/standard"

  before_each(function()
    state:load(fixture_path)
  end)

  after_each(function()
    state.manuscript = nil
    state.chapters = nil
    state.chapters_by_section = nil
    state.sections = nil
  end)

  it("holds section metadata", function()
    local data = { id = "p1x3q8", title = "Part 1", chapter_ids = { "chap1a", "chap1b", "chap1c" } }
    local section = Section.new(data, fixture_path)

    assert.equals(section.id, "p1x3q8")
    assert.equals(section.title, "Part 1")
    assert.equals(#section.chapter_ids, 3)
  end)

  it("resolves chapters in order from state", function()
    local section = state.sections["p1x3q8"]
    local chapters = section:chapters()

    assert.equals(#chapters, 3)
    assert.equals(chapters[1].title, "The Day I Became Sentient")
    assert.equals(chapters[2].title, "Bread: A Love Story")
    assert.equals(chapters[3].title, "The Kitchen Uprising")
  end)
end)
