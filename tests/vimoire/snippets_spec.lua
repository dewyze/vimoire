local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local state = require("vimoire.state")
local snippets = require("vimoire.snippets")

describe("snippets", function()
  local temp_dir
  local fixture_path = "tests/fixtures/standard"

  before_each(function()
    temp_dir = helpers.temp_copy(fixture_path)
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  describe("dir", function()
    it("returns snippets directory at book root", function()
      local dir = snippets.dir(temp_dir)
      assert.equals(temp_dir .. "/snippets", dir)
    end)
  end)

  describe("filepath", function()
    it("returns path to snippet file", function()
      local path = snippets.filepath(temp_dir, "abc123")
      assert.equals(temp_dir .. "/snippets/abc123.md", path)
    end)
  end)

  describe("parse", function()
    it("parses text and description from content", function()
      local content = "snippet text\n------\n#tag description"
      local result = snippets.parse(content)

      assert.equals("snippet text", result.text)
      assert.equals("#tag description", result.description)
    end)

    it("handles multiline text", function()
      local content = "line one\nline two\n------\nnotes"
      local result = snippets.parse(content)

      assert.equals("line one\nline two", result.text)
    end)

    it("returns nil description when empty", function()
      local content = "just text\n------\n"
      local result = snippets.parse(content)

      assert.equals("just text", result.text)
      assert.is_nil(result.description)
    end)

    it("handles content without separator", function()
      local content = "just text no separator"
      local result = snippets.parse(content)

      assert.equals("just text no separator", result.text)
      assert.is_nil(result.description)
    end)
  end)

  describe("format", function()
    it("formats text and description with separator", function()
      local result = snippets.format("my text", "#tags")
      assert.equals("my text\n------\n#tags", result)
    end)

    it("handles nil description", function()
      local result = snippets.format("my text", nil)
      assert.equals("my text\n------\n", result)
    end)
  end)

  describe("load", function()
    it("returns empty array when directory missing", function()
      local result = snippets.load(temp_dir)
      assert.same({}, result)
    end)

    it("returns snippets from files", function()
      local dir = snippets.dir(temp_dir)
      Path:new(dir):mkdir({ parents = true })
      Path:new(dir .. "/abc123.md"):write("test snippet\n------\n#tag", "w")

      local result = snippets.load(temp_dir)

      assert.equals(1, #result)
      assert.equals("abc123", result[1].id)
      assert.equals("test snippet", result[1].text)
      assert.equals("#tag", result[1].description)
    end)

    it("loads multiple snippets", function()
      local dir = snippets.dir(temp_dir)
      Path:new(dir):mkdir({ parents = true })
      Path:new(dir .. "/aaa111.md"):write("first\n------\n", "w")
      Path:new(dir .. "/bbb222.md"):write("second\n------\n", "w")

      local result = snippets.load(temp_dir)

      assert.equals(2, #result)
    end)
  end)

  describe("add", function()
    it("creates snippets directory if missing", function()
      local dir = snippets.dir(temp_dir)

      snippets.add(temp_dir, "hello world", "#test")

      assert.is_true(Path:new(dir):exists())
    end)

    it("creates snippet file", function()
      local s = snippets.add(temp_dir, "hello world", "#test")

      local filepath = snippets.filepath(temp_dir, s.id)
      assert.is_true(Path:new(filepath):exists())
    end)

    it("writes text and description to file", function()
      local s = snippets.add(temp_dir, "my text", "#description")

      local filepath = snippets.filepath(temp_dir, s.id)
      local content = Path:new(filepath):read()

      assert.equals("my text\n------\n#description", content)
    end)

    it("generates unique IDs", function()
      local s1 = snippets.add(temp_dir, "first", nil)
      local s2 = snippets.add(temp_dir, "second", nil)

      assert.is_not_nil(s1.id)
      assert.is_not_nil(s2.id)
      assert.not_equals(s1.id, s2.id)
    end)

    it("returns the new snippet", function()
      local s = snippets.add(temp_dir, "my text", "#notes")

      assert.equals("my text", s.text)
      assert.equals("#notes", s.description)
      assert.is_string(s.id)
      assert.equals(6, #s.id)
    end)
  end)

  describe("update", function()
    it("updates text of existing snippet", function()
      local s = snippets.add(temp_dir, "original", nil)

      local updated = snippets.update(temp_dir, s.id, { text = "modified" })

      assert.equals("modified", updated.text)
      local reloaded = snippets.load(temp_dir)
      assert.equals("modified", reloaded[1].text)
    end)

    it("updates description of existing snippet", function()
      local s = snippets.add(temp_dir, "text", nil)

      snippets.update(temp_dir, s.id, { description = "#new-tag" })

      local reloaded = snippets.load(temp_dir)
      assert.equals("#new-tag", reloaded[1].description)
    end)

    it("updates multiple fields at once", function()
      local s = snippets.add(temp_dir, "original", "#old")

      snippets.update(temp_dir, s.id, { text = "new text", description = "#new" })

      local reloaded = snippets.load(temp_dir)
      assert.equals("new text", reloaded[1].text)
      assert.equals("#new", reloaded[1].description)
    end)

    it("returns nil for non-existent ID", function()
      snippets.add(temp_dir, "test", nil)

      local result = snippets.update(temp_dir, "nonexistent", { text = "whatever" })

      assert.is_nil(result)
    end)

    it("preserves other snippet files", function()
      local s1 = snippets.add(temp_dir, "first", "#one")
      local s2 = snippets.add(temp_dir, "second", "#two")

      snippets.update(temp_dir, s1.id, { text = "updated first" })

      local filepath2 = snippets.filepath(temp_dir, s2.id)
      local content = Path:new(filepath2):read()
      assert.equals("second\n------\n#two", content)
    end)
  end)

  describe("remove", function()
    it("removes snippet file", function()
      local s = snippets.add(temp_dir, "test", nil)
      local filepath = snippets.filepath(temp_dir, s.id)

      local result = snippets.remove(temp_dir, s.id)

      assert.is_true(result)
      assert.is_false(Path:new(filepath):exists())
    end)

    it("returns false for non-existent ID", function()
      snippets.add(temp_dir, "test", nil)

      local result = snippets.remove(temp_dir, "nonexistent")

      assert.is_false(result)
    end)

    it("handles empty snippets directory", function()
      local result = snippets.remove(temp_dir, "anyid")
      assert.is_false(result)
    end)
  end)
end)
