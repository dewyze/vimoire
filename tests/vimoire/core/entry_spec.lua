local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("Entry", function()
  local Entry = require("vimoire.core.entry")

  it("holds entry metadata", function()
    local data = { id = "chap1a", kind = "chapter", title = "The Day I Became Sentient", section = "p1x3q8" }
    local entry = Entry.new(data, "/some/root")
    assert.equals(entry.id, "chap1a")
    assert.equals(entry.kind, "chapter")
    assert.equals(entry.title, "The Day I Became Sentient")
    assert.equals(entry.section, "p1x3q8")
  end)

  describe("display_number", function()
    it("returns nil for page entries", function()
      local entry = Entry.new({ id = "p1", kind = "page", title = "Test" }, "/root")
      entry.chapter_index = 3
      assert.is_nil(entry:display_number())
    end)

    it("returns chapter index when no section index", function()
      local entry = Entry.new({ id = "ch1", kind = "chapter", title = "Test" }, "/root")
      entry.chapter_index = 3
      assert.equals("3", entry:display_number())
    end)

    it("returns section.chapter when section index present", function()
      local entry = Entry.new({ id = "ch1", kind = "chapter", title = "Test" }, "/root")
      entry.section_index = 2
      entry.chapter_index = 5
      assert.equals("2.5", entry:display_number())
    end)
  end)

  describe("paths", function()
    it("returns text_path in entries folder", function()
      local entry = Entry.new({ id = "abc123", kind = "chapter", title = "Test" }, "/some/root")
      assert.equals("/some/root/entries/abc123/text.md", entry:text_path())
    end)

    it("returns notes_path in entries folder", function()
      local entry = Entry.new({ id = "abc123", kind = "chapter", title = "Test" }, "/some/root")
      assert.equals("/some/root/entries/abc123/notes.md", entry:notes_path())
    end)
  end)

  -- Mutation tests (create/update/destroy/move)

  describe("mutations", function()
    local temp_dir
    local fixture_path = "tests/fixtures/standard"

    -- Local assertion helpers

    local function assert_entry(entry_id, opts)
      opts = opts or {}

      local function check()
        local entry = state.entries[entry_id]
        assert.is_not_nil(entry, "Entry " .. entry_id .. " should exist")

        if opts.title then
          assert.equals(opts.title, entry.title)
        end

        if opts.kind then
          assert.equals(opts.kind, entry.kind)
        end

        if opts.section then
          local section = state.sections[opts.section]
          assert.is_not_nil(section, "Section " .. opts.section .. " should exist")

          local found = false
          for _, e in ipairs(section.entries) do
            if e.id == entry_id then found = true end
          end
          assert.is_true(found, "Entry " .. entry_id .. " should be in section " .. opts.section)

          if opts.position then
            assert.equals(entry_id, section.entries[opts.position].id,
              "Entry " .. entry_id .. " should be at position " .. opts.position)
          end
        end

        if opts.dir then
          local entry_dir = Path:new(opts.dir, "entries", entry_id)
          assert.is_true(entry_dir:exists(), "Entry dir should exist: " .. entry_id)
        end
      end

      check()

      if opts.dir then
        state:load(opts.dir)
        check()
      end
    end

    local function assert_entry_removed(entry_id, opts)
      opts = opts or {}

      local function check()
        assert.is_nil(state.entries[entry_id], "Entry " .. entry_id .. " should not exist")

        if opts.dir then
          local entry_dir = Path:new(opts.dir, "entries", entry_id)
          assert.is_false(entry_dir:exists(), "Entry dir should not exist: " .. entry_id)
        end
      end

      check()

      if opts.dir then
        state:load(opts.dir)
        check()
      end
    end

    local function assert_section_order(section_id, expected_ids, opts)
      opts = opts or {}

      local function check()
        local section = state.sections[section_id]
        assert.is_not_nil(section, "Section " .. section_id .. " should exist")

        local actual_ids = {}
        for _, e in ipairs(section.entries) do
          table.insert(actual_ids, e.id)
        end
        assert.same(expected_ids, actual_ids)
      end

      check()

      if opts.dir then
        state:load(opts.dir)
        check()
      end
    end

    before_each(function()
      temp_dir = helpers.create_temp_fixture(fixture_path)
      state:load(temp_dir)
    end)

    after_each(function()
      helpers.cleanup_temp_fixture(temp_dir)
      helpers.reset_state()
    end)

    describe("create", function()
      it("creates a new chapter entry in section", function()
        local entry = Entry.create(state, "chapter", "A New Chapter", "p1x3q8")

        assert.is_not_nil(entry)
        assert_entry(entry.id, {
          title = "A New Chapter",
          kind = "chapter",
          section = "p1x3q8",
          dir = temp_dir,
        })
      end)

      it("creates a new page entry in section", function()
        local entry = Entry.create(state, "page", "Interlude", "p1x3q8")

        assert.is_not_nil(entry)
        assert_entry(entry.id, {
          title = "Interlude",
          kind = "page",
          section = "p1x3q8",
          dir = temp_dir,
        })
      end)

      it("creates unsectioned entry when section_id is nil", function()
        local entry = Entry.create(state, "chapter", "Standalone Chapter", nil)

        assert.is_not_nil(entry)
        assert.is_nil(entry.section)
        assert_entry(entry.id, {
          title = "Standalone Chapter",
          kind = "chapter",
          dir = temp_dir,
        })
      end)

      it("returns error for non-existent section", function()
        local result, err = Entry.create(state, "chapter", "Test", "nonexistent")

        assert.is_nil(result)
        assert.matches("Section not found", err)
      end)
    end)

    describe("update", function()
      it("updates the entry title", function()
        local entry = state.entries["chap1a"]
        local updated = entry:update(state, { title = "Renamed Entry" })

        assert.equals("Renamed Entry", updated.title)
        assert_entry("chap1a", {
          title = "Renamed Entry",
          dir = temp_dir,
        })
      end)
    end)

    describe("destroy", function()
      it("removes the entry", function()
        local entry = state.entries["chap1a"]
        local result = entry:destroy(state)

        assert.is_true(result)
        assert_entry_removed("chap1a", { dir = temp_dir })
      end)
    end)

    describe("move", function()
      it("moves entry to new position in same section", function()
        -- Original: [part1tp, chap1a, chap1b, chap1c]
        -- Move chap1a to position 3
        -- Result: [part1tp, chap1b, chap1a, chap1c]
        local entry = state.entries["chap1a"]
        entry:move(state, "p1x3q8", 3)

        assert_section_order("p1x3q8", { "part1tp", "chap1b", "chap1a", "chap1c" }, { dir = temp_dir })
      end)

      it("moves entry to different section", function()
        -- Original p1x3q8: [part1tp, chap1a, chap1b, chap1c]
        -- Original p2y5r4: [chap2a, chap2b]
        -- Move chap1a to position 2 in p2y5r4
        -- Result p1x3q8: [part1tp, chap1b, chap1c]
        -- Result p2y5r4: [chap2a, chap1a, chap2b]
        local entry = state.entries["chap1a"]
        entry:move(state, "p2y5r4", 2)

        assert_section_order("p1x3q8", { "part1tp", "chap1b", "chap1c" }, { dir = temp_dir })
        assert_section_order("p2y5r4", { "chap2a", "chap1a", "chap2b" }, { dir = temp_dir })
      end)

      it("returns error for non-existent target section", function()
        local entry = state.entries["chap1a"]
        local result, err = entry:move(state, "nonexistent", 1)

        assert.is_nil(result)
        assert.matches("Section not found", err)
      end)
    end)
  end)
end)
