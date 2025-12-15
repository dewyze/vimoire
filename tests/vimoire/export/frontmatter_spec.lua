local assert = require("luassert")

describe("frontmatter", function()
  local frontmatter = require("vimoire.export.frontmatter")

  describe("parse", function()
    it("parses simple frontmatter", function()
      local content = "---\ntitle: Hello World\n---\nBody text"
      local fm, body = frontmatter.parse(content)
      assert.equals("Hello World", fm.title)
      assert.equals("Body text", body)
    end)

    it("parses multiple fields", function()
      local content = "---\ntitle: My Chapter\nsubtitle: A journey\nepigraph: To be or not\n---\nBody"
      local fm, body = frontmatter.parse(content)
      assert.equals("My Chapter", fm.title)
      assert.equals("A journey", fm.subtitle)
      assert.equals("To be or not", fm.epigraph)
      assert.equals("Body", body)
    end)

    it("returns empty table when no frontmatter", function()
      local content = "Just regular content\nwith lines"
      local fm, body = frontmatter.parse(content)
      assert.same({}, fm)
      assert.equals(content, body)
    end)

    it("returns empty table for empty content", function()
      local fm, body = frontmatter.parse("")
      assert.same({}, fm)
      assert.equals("", body)
    end)

    it("returns empty table for nil content", function()
      local fm, body = frontmatter.parse(nil)
      assert.same({}, fm)
      assert.equals("", body)
    end)

    it("handles frontmatter without closing delimiter", function()
      local content = "---\ntitle: Broken\nNo closing"
      local fm, body = frontmatter.parse(content)
      assert.same({}, fm)
      assert.equals(content, body)
    end)

    it("handles empty frontmatter", function()
      local content = "---\n---\nBody only"
      local fm, body = frontmatter.parse(content)
      assert.same({}, fm)
      assert.equals("Body only", body)
    end)

    it("handles body with leading newline", function()
      local content = "---\ntitle: Test\n---\n\nBody with space"
      local fm, body = frontmatter.parse(content)
      assert.equals("Test", fm.title)
      assert.equals("\nBody with space", body)
    end)

    it("handles invalid YAML gracefully", function()
      local content = "---\n: broken yaml [\n---\nBody"
      local fm, body = frontmatter.parse(content)
      assert.same({}, fm)
      assert.equals("Body", body)
    end)
  end)
end)
