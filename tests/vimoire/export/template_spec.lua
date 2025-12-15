local assert = require("luassert")

describe("template", function()
  local template = require("vimoire.export.template")

  describe("render", function()
    it("substitutes single placeholder", function()
      local result = template.render("Hello {{name}}", { name = "World" })
      assert.equals("Hello World", result)
    end)

    it("substitutes multiple placeholders", function()
      local result = template.render("{{a}} and {{b}}", { a = "One", b = "Two" })
      assert.equals("One and Two", result)
    end)

    it("replaces missing values with empty string", function()
      local result = template.render("Hello {{name}}", {})
      assert.equals("Hello ", result)
    end)

    it("converts numbers to strings", function()
      local result = template.render("Chapter {{num}}", { num = 5 })
      assert.equals("Chapter 5", result)
    end)

    it("handles template with no placeholders", function()
      local result = template.render("No placeholders here", { foo = "bar" })
      assert.equals("No placeholders here", result)
    end)

    it("renders default chapter template", function()
      local result = template.render(template.DEFAULT_CHAPTER, { num = 3, title = "The Beginning" })
      assert.equals("# Chapter 3: The Beginning\n\n", result)
    end)
  end)
end)
