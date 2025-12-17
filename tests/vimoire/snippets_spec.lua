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

  describe("path", function()
    it("returns snippets.json at book root", function()
      local path = snippets.path(temp_dir)
      assert.equals(temp_dir .. "/snippets.json", path)
    end)
  end)

  describe("load", function()
    it("returns empty array when file missing", function()
      local result = snippets.load(temp_dir)
      assert.same({}, result)
    end)

    it("returns snippets when file exists", function()
      local snippet_path = snippets.path(temp_dir)
      Path:new(snippet_path):write(vim.json.encode({
        { id = "abc123", text = "test snippet", created_at = "2025-01-01T00:00:00Z" }
      }), "w")

      local result = snippets.load(temp_dir)
      assert.equals(1, #result)
      assert.equals("test snippet", result[1].text)
    end)

    it("returns empty array for corrupt JSON", function()
      local snippet_path = snippets.path(temp_dir)
      Path:new(snippet_path):write("not valid json", "w")

      local result = snippets.load(temp_dir)
      assert.same({}, result)
    end)
  end)

  describe("add", function()
    it("creates snippets.json if missing", function()
      local snippet_path = snippets.path(temp_dir)

      snippets.add(temp_dir, "hello world", "chap1a", "Test Chapter")

      assert.is_true(Path:new(snippet_path):exists())
      local result = snippets.load(temp_dir)
      assert.equals(1, #result)
      assert.equals("hello world", result[1].text)
    end)

    it("appends to existing snippets", function()
      snippets.add(temp_dir, "first", nil, nil)
      snippets.add(temp_dir, "second", nil, nil)

      local result = snippets.load(temp_dir)
      assert.equals(2, #result)
      assert.equals("first", result[1].text)
      assert.equals("second", result[2].text)
    end)

    it("generates unique IDs", function()
      local s1 = snippets.add(temp_dir, "first", nil, nil)
      local s2 = snippets.add(temp_dir, "second", nil, nil)

      assert.is_not_nil(s1.id)
      assert.is_not_nil(s2.id)
      assert.not_equals(s1.id, s2.id)
    end)

    it("sets created_at timestamp", function()
      local s = snippets.add(temp_dir, "test", nil, nil)

      assert.is_not_nil(s.created_at)
      assert.matches("^%d%d%d%d%-%d%d%-%d%dT", s.created_at)
    end)

    it("stores source_id and source_name", function()
      local s = snippets.add(temp_dir, "my text", "chap1a", "1: The Day I Became Sentient")

      assert.equals("chap1a", s.source_id)
      assert.equals("1: The Day I Became Sentient", s.source_name)
    end)

    it("allows nil source info", function()
      local s = snippets.add(temp_dir, "orphan text", nil, nil)

      assert.is_nil(s.source_id)
      assert.is_nil(s.source_name)
    end)

    it("returns the new snippet", function()
      local s = snippets.add(temp_dir, "my text", nil, nil)

      assert.equals("my text", s.text)
      assert.is_string(s.id)
      assert.equals(6, #s.id)
    end)
  end)

  describe("remove", function()
    it("removes snippet by ID", function()
      local s1 = snippets.add(temp_dir, "first", nil, nil)
      snippets.add(temp_dir, "second", nil, nil)

      local result = snippets.remove(temp_dir, s1.id)

      assert.is_true(result)
      local remaining = snippets.load(temp_dir)
      assert.equals(1, #remaining)
      assert.equals("second", remaining[1].text)
    end)

    it("returns false for non-existent ID", function()
      snippets.add(temp_dir, "test", nil, nil)

      local result = snippets.remove(temp_dir, "nonexistent")

      assert.is_false(result)
    end)

    it("handles empty snippets list", function()
      local result = snippets.remove(temp_dir, "anyid")
      assert.is_false(result)
    end)
  end)
end)
