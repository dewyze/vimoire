local assert = require("luassert")

describe("preprocess", function()
  local preprocess = require("vimoire.export.preprocess")

  describe("paragraph_breaks", function()
    it("converts single newlines to double newlines", function()
      local input = "Line one\nLine two"
      local output = preprocess.paragraph_breaks(input)
      assert.equals("Line one\n\nLine two", output)
    end)

    it("preserves existing double newlines", function()
      local input = "Line one\n\nLine two"
      local output = preprocess.paragraph_breaks(input)
      assert.equals("Line one\n\nLine two", output)
    end)

    it("handles multiple single newlines", function()
      local input = "One\nTwo\nThree"
      local output = preprocess.paragraph_breaks(input)
      assert.equals("One\n\nTwo\n\nThree", output)
    end)

    it("handles empty string", function()
      local output = preprocess.paragraph_breaks("")
      assert.equals("", output)
    end)
  end)

  describe("chapter", function()
    it("replaces {{chapter.num}} and {{chapter.title}}", function()
      local input = "# Chapter {{chapter.num}}: {{chapter.title}}"
      local output = preprocess.chapter(input, { num = 3, title = "The Beginning" })
      assert.equals("# Chapter 3: The Beginning", output)
    end)

    it("leaves unmatched placeholders unchanged", function()
      local input = "Chapter {{chapter.num}} by {{chapter.unknown}}"
      local output = preprocess.chapter(input, { num = 5 })
      assert.equals("Chapter 5 by {{chapter.unknown}}", output)
    end)

    it("handles missing context gracefully", function()
      local input = "Chapter {{chapter.num}}"
      local output = preprocess.chapter(input, {})
      assert.equals("Chapter {{chapter.num}}", output)
    end)
  end)

  describe("strip_tags", function()
    it("removes {{mark}}", function()
      local input = "He walked {{mark}}slowly to the door."
      local output = preprocess.strip_tags(input)
      assert.equals("He walked slowly to the door.", output)
    end)

    it("removes {{mark:title}}", function()
      local input = "This {{mark:needs work}}paragraph continues."
      local output = preprocess.strip_tags(input)
      assert.equals("This paragraph continues.", output)
    end)

    it("removes {{todo}}", function()
      local input = "This needs work {{todo}} here."
      local output = preprocess.strip_tags(input)
      assert.equals("This needs work  here.", output)
    end)

    it("removes {{todo:description}}", function()
      local input = "She pulled out {{todo:what object?}} from her pocket."
      local output = preprocess.strip_tags(input)
      assert.equals("She pulled out  from her pocket.", output)
    end)

    it("strips trailing newline after tag", function()
      local input = "{{mark:rewrite}}\nThe paragraph."
      local output = preprocess.strip_tags(input)
      assert.equals("The paragraph.", output)
    end)

    it("preserves paragraph breaks after tag", function()
      local input = "{{mark}}\n\nNext paragraph."
      local output = preprocess.strip_tags(input)
      assert.equals("\nNext paragraph.", output)
    end)
  end)

  describe("strip_indent", function()
    it("removes leading tab from each line", function()
      local input = "\tFirst paragraph.\n\tSecond paragraph."
      local output = preprocess.strip_indent(input)
      assert.equals("First paragraph.\nSecond paragraph.", output)
    end)

    it("preserves lines without leading tabs", function()
      local input = "# Heading\n\tParagraph text."
      local output = preprocess.strip_indent(input)
      assert.equals("# Heading\nParagraph text.", output)
    end)

    it("only strips one leading tab", function()
      local input = "\t\tDouble indented."
      local output = preprocess.strip_indent(input)
      assert.equals("\tDouble indented.", output)
    end)

    it("handles empty lines", function()
      local input = "\tFirst.\n\n\tSecond."
      local output = preprocess.strip_indent(input)
      assert.equals("First.\n\nSecond.", output)
    end)
  end)

  describe("book", function()
    it("replaces {{book.title}}, {{book.author}}, etc.", function()
      local input = "{{book.title}} by {{book.author}}\n{{book.copyright}}"
      local output = preprocess.book(input, {
        title = "My Novel",
        author = "Jane Doe",
        copyright = "© 2025 Jane Doe",
      })
      assert.equals("My Novel by Jane Doe\n© 2025 Jane Doe", output)
    end)

    it("leaves unmatched placeholders unchanged", function()
      local input = "{{book.title}} - {{book.unknown}}"
      local output = preprocess.book(input, { title = "Test" })
      assert.equals("Test - {{book.unknown}}", output)
    end)
  end)
end)
