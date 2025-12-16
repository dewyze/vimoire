local assert = require("luassert")
local helpers = require("tests.helpers")

describe("collector", function()
  local collector = require("vimoire.export.collector")
  local state = require("vimoire.state")
  local temp_dir

  before_each(function()
    temp_dir = helpers.temp_copy("tests/fixtures/standard")
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  describe("collect_entries", function()
    it("collects entries in manuscript order", function()
      local entries = collector.collect_entries(state)

      assert.equals(9, #entries)
      assert.equals("part1tp", entries[1].id)
      assert.equals("chap1a", entries[2].id)
      assert.equals("chap1b", entries[3].id)
    end)

    it("returns path from entry:text_path()", function()
      local entries = collector.collect_entries(state)

      assert.truthy(entries[1].path:match("/entries/part1tp/prose.md$"))
    end)

    it("chapters have num from chapter_index", function()
      local entries = collector.collect_entries(state)

      -- chap1a is chapter 1, chap1b is chapter 2
      assert.equals(1, entries[2].context.num)
      assert.equals(2, entries[3].context.num)
    end)

    it("pages have no num", function()
      local entries = collector.collect_entries(state)

      assert.is_nil(entries[1].context.num)
    end)

    it("all entries have title from entry name", function()
      local entries = collector.collect_entries(state)

      assert.equals("Part One", entries[1].context.title)
      assert.equals("The Day I Became Sentient", entries[2].context.title)
    end)
  end)

  describe("collect_by_ids", function()
    it("returns entries matching given IDs", function()
      local entries = collector.collect_by_ids(state, { "chap1a", "chap1b" })

      assert.equals(2, #entries)
      assert.equals("chap1a", entries[1].id)
      assert.equals("chap1b", entries[2].id)
    end)

    it("preserves order of IDs provided", function()
      local entries = collector.collect_by_ids(state, { "chap1b", "chap1a" })

      assert.equals("chap1b", entries[1].id)
      assert.equals("chap1a", entries[2].id)
    end)

    it("skips IDs not in manuscript", function()
      local entries = collector.collect_by_ids(state, { "chap1a", "nonexistent", "chap1b" })

      assert.equals(2, #entries)
      assert.equals("chap1a", entries[1].id)
      assert.equals("chap1b", entries[2].id)
    end)

    it("returns entries with path and context", function()
      local entries = collector.collect_by_ids(state, { "chap1a" })

      assert.truthy(entries[1].path:match("/entries/chap1a/prose.md$"))
      assert.equals("The Day I Became Sentient", entries[1].context.title)
      assert.equals(1, entries[1].context.num)
    end)
  end)
end)
