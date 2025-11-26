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
end)
