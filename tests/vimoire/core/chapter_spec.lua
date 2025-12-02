local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("Chapter", function()
  local Chapter = require("vimoire.core.chapter")

  it("holds chapter metadata", function()
    local data = { id = "chap1a", title = "The Day I Became Sentient", section = "p1x3q8" }
    local chapter = Chapter.new(data)
    assert.equals(chapter.id, "chap1a")
    assert.equals(chapter.title, "The Day I Became Sentient")
    assert.equals(chapter.section, "p1x3q8")
  end)

  describe("display_number", function()
    it("returns chapter index when no section index", function()
      local chapter = Chapter.new({ id = "ch1", title = "Test" })
      chapter.chapter_index = 3
      assert.equals("3", chapter:display_number())
    end)

    it("returns section.chapter when section index present", function()
      local chapter = Chapter.new({ id = "ch1", title = "Test" })
      chapter.section_index = 2
      chapter.chapter_index = 5
      assert.equals("2.5", chapter:display_number())
    end)
  end)

  -- Mutation tests (create/update/destroy/move)

  describe("mutations", function()
    local temp_dir
    local fixture_path = "tests/fixtures/standard"

    -- Local assertion helpers

    local function assert_chapter(chapter_id, opts)
      opts = opts or {}

      local function check()
        local chapter = state.chapters[chapter_id]
        assert.is_not_nil(chapter, "Chapter " .. chapter_id .. " should exist")

        if opts.title then
          assert.equals(opts.title, chapter.title)
        end

        if opts.section then
          local section = state.sections[opts.section]
          assert.is_not_nil(section, "Section " .. opts.section .. " should exist")

          local found = false
          for _, ch in ipairs(section.chapters) do
            if ch.id == chapter_id then found = true end
          end
          assert.is_true(found, "Chapter " .. chapter_id .. " should be in section " .. opts.section)

          if opts.position then
            assert.equals(chapter_id, section.chapters[opts.position].id,
              "Chapter " .. chapter_id .. " should be at position " .. opts.position)
          end
        end

        if opts.dir then
          local chapter_dir = Path:new(opts.dir, "chapters", chapter_id)
          assert.is_true(chapter_dir:exists(), "Chapter dir should exist: " .. chapter_id)
        end
      end

      check()

      if opts.dir then
        state:load(opts.dir)
        check()
      end
    end

    local function assert_chapter_removed(chapter_id, opts)
      opts = opts or {}

      local function check()
        assert.is_nil(state.chapters[chapter_id], "Chapter " .. chapter_id .. " should not exist")

        if opts.dir then
          local chapter_dir = Path:new(opts.dir, "chapters", chapter_id)
          assert.is_false(chapter_dir:exists(), "Chapter dir should not exist: " .. chapter_id)
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
        for _, ch in ipairs(section.chapters) do
          table.insert(actual_ids, ch.id)
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
      it("creates a new chapter in section", function()
        local chapter = Chapter.create(state, "p1x3q8", "A New Chapter")

        assert.is_not_nil(chapter)
        assert_chapter(chapter.id, {
          title = "A New Chapter",
          section = "p1x3q8",
          dir = temp_dir,
        })
      end)

      it("returns error for non-existent section", function()
        local result, err = Chapter.create(state, "nonexistent", "Test")

        assert.is_nil(result)
        assert.matches("Section not found", err)
      end)
    end)

    describe("update", function()
      it("updates the chapter title", function()
        local chapter = state.chapters["chap1a"]
        local updated = chapter:update(state, { title = "Renamed Chapter" })

        assert.equals("Renamed Chapter", updated.title)
        assert_chapter("chap1a", {
          title = "Renamed Chapter",
          dir = temp_dir,
        })
      end)
    end)

    describe("destroy", function()
      it("removes the chapter", function()
        local chapter = state.chapters["chap1a"]
        local result = chapter:destroy(state)

        assert.is_true(result)
        assert_chapter_removed("chap1a", { dir = temp_dir })
      end)
    end)

    describe("move", function()
      it("moves chapter to new position in same section", function()
        -- Original: [chap1a, chap1b, chap1c]
        -- Move chap1a to position 2
        -- Result: [chap1b, chap1a, chap1c] - b shifts up, c stays
        local chapter = state.chapters["chap1a"]
        chapter:move(state, "p1x3q8", 2)

        assert_section_order("p1x3q8", { "chap1b", "chap1a", "chap1c" }, { dir = temp_dir })
      end)

      it("moves chapter to different section", function()
        -- Original p1x3q8: [chap1a, chap1b, chap1c]
        -- Original p2y5r4: [chap2a, chap2b]
        -- Move chap1a to position 2 in p2y5r4
        -- Result p1x3q8: [chap1b, chap1c]
        -- Result p2y5r4: [chap2a, chap1a, chap2b] - 2a stays, 2b shifts down
        local chapter = state.chapters["chap1a"]
        chapter:move(state, "p2y5r4", 2)

        assert_section_order("p1x3q8", { "chap1b", "chap1c" }, { dir = temp_dir })
        assert_section_order("p2y5r4", { "chap2a", "chap1a", "chap2b" }, { dir = temp_dir })
      end)

      it("returns error for non-existent target section", function()
        local chapter = state.chapters["chap1a"]
        local result, err = chapter:move(state, "nonexistent", 1)

        assert.is_nil(result)
        assert.matches("Section not found", err)
      end)
    end)
  end)
end)
