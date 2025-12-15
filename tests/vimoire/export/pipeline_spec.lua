local assert = require("luassert")

describe("pipeline", function()
  local pipeline = require("vimoire.export.pipeline")
  local actions = require("vimoire.export.actions")

  describe("process_entry", function()
    it("runs actions from context", function()
      local content = "First paragraph.\nSecond paragraph.{{mark}}"
      local context = {
        num = 3,
        title = "The Beginning",
        actions = { actions.inject_title },
      }

      local result = pipeline.process_entry(content, context)

      assert.equals("# The Beginning\n\nFirst paragraph.\n\nSecond paragraph.", result)
    end)

    it("supports chapter.num placeholder in body", function()
      local content = "This is chapter {{chapter.num}}."
      local context = { num = 3, title = "Test", actions = {} }

      local result = pipeline.process_entry(content, context)

      assert.truthy(result:match("This is chapter 3."))
    end)

    it("skips title injection when no actions", function()
      local content = "The story begins."
      local context = { title = "Prologue", actions = {} }

      local result = pipeline.process_entry(content, context)

      assert.equals("The story begins.", result)
    end)

    it("strips todos and marks", function()
      local content = "{{todo:fix this}}He walked {{mark}}slowly."

      local result = pipeline.process_entry(content, { actions = {} })

      assert.equals("He walked slowly.", result)
    end)
  end)

  describe("process_front_matter", function()
    it("substitutes book placeholders", function()
      local content = "# {{book.title}}\n\nby {{book.author}}"
      local book = { title = "My Novel", author = "Jane Doe" }

      local result = pipeline.process_front_matter(content, book)

      assert.equals("# My Novel\n\nby Jane Doe", result)
    end)
  end)
end)
