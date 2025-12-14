local assert = require("luassert")

describe("Manuscript", function()
  local Manuscript = require("vimoire.core.manuscript")
  local example_path = "tests/fixtures/standard"

  it("loads a manuscript from disk", function()
    local manuscript = Manuscript.load(example_path)

    assert.is_not_nil(manuscript)
    assert.is_not_nil(manuscript.id)
  end)

  it("handles a missing manuscript", function()
    local manuscript = Manuscript.load("tests/fixtures/nonexistent")

    assert.is_nil(manuscript)
  end)

  it("has items array", function()
    local manuscript = Manuscript.load(example_path)

    assert.is_not_nil(manuscript.items)
    assert.equals(5, #manuscript.items) -- 2 sections + 3 unsectioned items
  end)

  it("has nested section items", function()
    local manuscript = Manuscript.load(example_path)

    local part1 = manuscript.items[1]
    assert.equals("section", part1.kind)
    assert.equals("Part 1", part1.name)
    assert.equals(4, #part1.items)
  end)

  it("saves manuscript back to disk", function()
    local manuscript = Manuscript.load(example_path)
    local ok = manuscript:save()

    assert.is_true(ok)
  end)

  it("detects sectioned manuscripts", function()
    local manuscript = Manuscript.load(example_path)
    assert.is_true(manuscript:sectioned())

    local flat = Manuscript.load("tests/fixtures/flat")
    assert.is_false(flat:sectioned())
  end)
end)
