local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("Section", function()
  local Section = require("vimoire.core.section")
  local fixture_path = "tests/fixtures/standard"

  before_each(function()
    state:load(fixture_path)
  end)

  after_each(function()
    helpers.reset_state()
  end)

  it("holds section metadata", function()
    local data = { id = "p1x3q8", title = "Part 1", visible = true }
    local section = Section.new(data)

    assert.equals(section.id, "p1x3q8")
    assert.equals(section.title, "Part 1")
    assert.equals(section.visible, true)
  end)

  it("resolves chapters in order from state", function()
    local section = state.sections["p1x3q8"]
    local chapters = section.chapters

    assert.equals(#chapters, 3)
    assert.equals(chapters[1].title, "The Day I Became Sentient")
    assert.equals(chapters[2].title, "Bread: A Love Story")
    assert.equals(chapters[3].title, "The Kitchen Uprising")
  end)

  -- Mutation tests

  describe("mutations", function()
    local temp_dir

    local function assert_section(section_id, opts)
      opts = opts or {}

      local function check()
        local section = state.sections[section_id]
        assert.is_not_nil(section, "Section " .. section_id .. " should exist")

        if opts.title then
          assert.equals(opts.title, section.title)
        end

        if opts.visible ~= nil then
          assert.equals(opts.visible, section.visible)
        end

        if opts.position then
          assert.equals(section_id, state.manuscript.sections[opts.position].id,
            "Section " .. section_id .. " should be at position " .. opts.position)
        end

        if opts.dir then
          local title_path = Path:new(opts.dir, "sections", section_id, "title.md")
          if opts.visible then
            assert.is_true(title_path:exists(), "Title page should exist for visible section")
          else
            assert.is_false(title_path:exists(), "Title page should not exist for invisible section")
          end
        end
      end

      check()

      if opts.dir then
        state:load(opts.dir)
        check()
      end
    end

    local function assert_section_removed(section_id, opts)
      opts = opts or {}

      local function check()
        assert.is_nil(state.sections[section_id], "Section " .. section_id .. " should not exist")
      end

      check()

      if opts.dir then
        state:load(opts.dir)
        check()
      end
    end

    local function assert_section_order(expected_ids, opts)
      opts = opts or {}

      local function check()
        local actual_ids = {}
        for _, sec_data in ipairs(state.manuscript.sections) do
          table.insert(actual_ids, sec_data.id)
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
      it("creates a new section", function()
        local section = Section.create(state, "Part 3")

        assert.is_not_nil(section)
        assert_section(section.id, {
          title = "Part 3",
          visible = false,
          position = 3,
          dir = temp_dir,
        })
      end)
    end)

    describe("update", function()
      it("updates the section title", function()
        local section = state.sections["p1x3q8"]
        local updated = section:update(state, { title = "Renamed Part" })

        assert.equals("Renamed Part", updated.title)
        assert_section("p1x3q8", {
          title = "Renamed Part",
          dir = temp_dir,
        })
      end)

      it("creates title page when setting visible to true", function()
        local section = state.sections["p1x3q8"]
        section.visible = false
        section:update(state, { visible = true })

        assert_section("p1x3q8", {
          visible = true,
          dir = temp_dir,
        })
      end)

      it("removes title page when setting visible to false", function()
        -- First create a title page
        local section = state.sections["p1x3q8"]
        section:update(state, { visible = true })

        -- Then remove it
        section:update(state, { visible = false })

        assert_section("p1x3q8", {
          visible = false,
          dir = temp_dir,
        })
      end)
    end)

    describe("destroy", function()
      it("removes the section and its chapters", function()
        local section = state.sections["p1x3q8"]
        local chapter_ids = { "chap1a", "chap1b", "chap1c" }
        local result = section:destroy(state)

        assert.is_true(result)
        assert_section_removed("p1x3q8", { dir = temp_dir })

        -- Chapters should also be gone
        for _, chapter_id in ipairs(chapter_ids) do
          assert.is_nil(state.chapters[chapter_id])
        end
      end)
    end)

    describe("move", function()
      it("moves section to new position", function()
        -- Original: [p1x3q8, p2y5r4]
        -- Move p1x3q8 to position 2
        -- Result: [p2y5r4, p1x3q8]
        local section = state.sections["p1x3q8"]
        section:move(state, 2)

        assert_section_order({ "p2y5r4", "p1x3q8" }, { dir = temp_dir })
      end)
    end)
  end)
end)
