local assert = require("luassert")

describe("pipeline", function()
  local pipeline = require("vimoire.export.pipeline")

  describe("process_entry", function()
    it("renders chapter opening from template", function()
      local content = "First paragraph.\nSecond paragraph."
      local context = { num = 3, title = "The Beginning" }
      local opts = {
        chapter_template = "# Chapter {{num}}: {{title}}\n\n",
        frontmatter = {},
      }

      local result = pipeline.process_entry(content, context, opts)

      assert.equals("# Chapter 3: The Beginning\n\nFirst paragraph.\n\nSecond paragraph.", result)
    end)

    it("uses frontmatter title over context title", function()
      local content = "Body text."
      local context = { num = 1, title = "Context Title" }
      local opts = {
        chapter_template = "# {{title}}\n\n",
        frontmatter = { title = "Frontmatter Title" },
      }

      local result = pipeline.process_entry(content, context, opts)

      assert.truthy(result:match("^# Frontmatter Title"))
    end)

    it("supports chapter.num placeholder in body", function()
      local content = "This is chapter {{chapter.num}}."
      local context = { num = 3, title = "Test" }

      local result = pipeline.process_entry(content, context)

      assert.truthy(result:match("This is chapter 3."))
    end)

    it("skips chapter opening when no num (pages)", function()
      local content = "The story begins."
      local context = { title = "Prologue" }
      local opts = {
        chapter_template = "# Chapter {{num}}: {{title}}\n\n",
        frontmatter = {},
      }

      local result = pipeline.process_entry(content, context, opts)

      assert.equals("The story begins.", result)
    end)

    it("strips todos and marks", function()
      local content = "{{todo:fix this}}He walked {{mark}}slowly."

      local result = pipeline.process_entry(content, {})

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
