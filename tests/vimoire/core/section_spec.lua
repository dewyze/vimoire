local assert = require("luassert")
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
    local data = { id = "p1x3q8", title = "Part 1" }
    local section = Section.new(data)

    assert.equals(section.id, "p1x3q8")
    assert.equals(section.title, "Part 1")
  end)

  it("resolves entries in order from state", function()
    local section = state.sections["p1x3q8"]
    local entries = section.entries

    assert.equals(#entries, 4)
    assert.equals(entries[1].title, "Part One")
    assert.equals(entries[2].title, "The Day I Became Sentient")
    assert.equals(entries[3].title, "Bread: A Love Story")
    assert.equals(entries[4].title, "The Kitchen Uprising")
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

        if opts.position then
          assert.equals(section_id, state.manuscript.sections[opts.position].id,
            "Section " .. section_id .. " should be at position " .. opts.position)
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
    end)

    describe("destroy", function()
      it("removes the section and ungroups its entries", function()
        local section = state.sections["p1x3q8"]
        local entry_ids = { "chap1a", "chap1b", "chap1c" }
        local result = section:destroy(state)

        assert.is_true(result)
        assert_section_removed("p1x3q8", { dir = temp_dir })

        -- Entries should still exist but be ungrouped
        for _, entry_id in ipairs(entry_ids) do
          local entry = state.entries[entry_id]
          assert.is_not_nil(entry, "Entry " .. entry_id .. " should still exist")
          assert.is_nil(entry.section, "Entry " .. entry_id .. " should be ungrouped")
        end
      end)
    end)
  end)
end)
