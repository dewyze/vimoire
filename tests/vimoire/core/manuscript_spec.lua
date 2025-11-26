local assert = require("luassert")

describe("Manuscript", function()
  local Manuscript = require("vimoire.core.manuscript")
  local example_path = "tests/fixtures/standard"

  it("loads a manuscript from disk", function()
    local manuscript = Manuscript.load(example_path)

    assert.equals(manuscript.title, "The Unreliable Memoirs of Gerald the Sentient Toaster")
    assert.equals(manuscript.description, "A tragic comedy in five acts, mostly about bread")
  end)

  it("handles a missing manuscript", function()
    local manuscript = Manuscript.load("tests/fixtures/nonexistent")

    assert.is_nil(manuscript)
  end)

  it("has correct section count", function()
    local manuscript = Manuscript.load(example_path)

    assert.equals(#manuscript.sections, 2)
  end)

  it("has correct chapter count", function()
    local manuscript = Manuscript.load(example_path)

    assert.equals(vim.tbl_count(manuscript.chapters), 5)
  end)

  it("saves manuscript back to disk", function()
    local manuscript = Manuscript.load(example_path)
    local ok = manuscript:save()

    assert.is_true(ok)
  end)
end)
