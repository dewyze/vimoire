local assert = require("luassert")

describe("actions", function()
  local actions = require("vimoire.export.actions")

  describe("inject_title", function()
    it("prepends H1 title to content", function()
      local output = actions.inject_title("Body text.", { title = "Chapter One" })
      assert.equals("# Chapter One\n\nBody text.", output)
    end)

    it("returns content unchanged when title is nil", function()
      local output = actions.inject_title("Body text.", {})
      assert.equals("Body text.", output)
    end)
  end)
end)
