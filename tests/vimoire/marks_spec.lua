local assert = require("luassert")
local helpers = require("tests.helpers")
local marks = require("vimoire.marks")

describe("marks", function()
  local fixture_content

  before_each(function()
    fixture_content = helpers.read_file("tests/fixtures/prose/marks_test.md")
  end)

  describe("parse", function()
    it("returns empty table for content without marks", function()
      local result = marks.parse("Just some text without any marks.")
      assert.same({}, result)
    end)

    it("finds plain {{mark}} tags", function()
      local result = marks.parse("Here is a {{mark}} in text.")

      assert.equals(1, #result)
      assert.equals(1, result[1].line)
      assert.is_nil(result[1].text)
    end)

    it("finds {{mark:text}} tags with description", function()
      local result = marks.parse("Here is {{mark:needs work}} in text.")

      assert.equals(1, #result)
      assert.equals(1, result[1].line)
      assert.equals("needs work", result[1].text)
    end)

    it("captures column position", function()
      local result = marks.parse("12345{{mark}}rest")

      assert.equals(6, result[1].col)
    end)

    it("handles multiple marks on one line", function()
      local result = marks.parse("First {{mark}} and {{mark:second}} here.")

      assert.equals(2, #result)
      assert.equals(1, result[1].line)
      assert.equals(1, result[2].line)
      assert.is_nil(result[1].text)
      assert.equals("second", result[2].text)
    end)

    it("tracks correct line numbers across multiple lines", function()
      local content = "Line one\nLine two {{mark}}\nLine three\nLine four {{mark:here}}"
      local result = marks.parse(content)

      assert.equals(2, #result)
      assert.equals(2, result[1].line)
      assert.equals(4, result[2].line)
    end)

    it("parses the fixture file correctly", function()
      local result = marks.parse(fixture_content)

      assert.equals(6, #result)

      -- Line 3: plain mark
      assert.equals(3, result[1].line)
      assert.is_nil(result[1].text)

      -- Line 7: mark with text
      assert.equals(7, result[2].line)
      assert.equals("research needed", result[2].text)

      -- Line 11: mark with text
      assert.equals(11, result[3].line)
      assert.equals("what object?", result[3].text)

      -- Line 13: two marks (plain and with text)
      assert.equals(13, result[4].line)
      assert.is_nil(result[4].text)
      assert.equals(13, result[5].line)
      assert.equals("fix this", result[5].text)

      -- Line 15: mark with text
      assert.equals(15, result[6].line)
      assert.equals("ending needs work", result[6].text)
    end)
  end)
end)
