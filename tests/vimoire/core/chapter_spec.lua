local assert = require("luassert")

describe("Chapter", function()
  local Chapter = require("vimoire.core.chapter")

  it("holds chapter metadata", function()
    local data = { id = "chap1a", title = "The Day I Became Sentient", section = "p1x3q8" }
    local chapter = Chapter.new(data)
    assert.equals(chapter.id, "chap1a")
    assert.equals(chapter.title, "The Day I Became Sentient")
    assert.equals(chapter.section, "p1x3q8")
  end)

  describe("display_number", function()
    it("returns chapter index when no section index", function()
      local chapter = Chapter.new({ id = "ch1", title = "Test" })
      chapter.chapter_index = 3
      assert.equals("3", chapter:display_number())
    end)

    it("returns section.chapter when section index present", function()
      local chapter = Chapter.new({ id = "ch1", title = "Test" })
      chapter.section_index = 2
      chapter.chapter_index = 5
      assert.equals("2.5", chapter:display_number())
    end)
  end)
end)
