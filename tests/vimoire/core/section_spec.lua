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
    local data = { id = "p1x3q8", name = "Part 1", items = {} }
    local section = Section.new(data, "/root")

    assert.equals("p1x3q8", section.id)
    assert.equals("Part 1", section.name)
    assert.equals("section", section.kind)
  end)

  it("has items array", function()
    local section = state.items["p1x3q8"]
    assert.is_not_nil(section.items)
    assert.equals(4, #section.items)
  end)

  it("returns nil for text_path and notes_path", function()
    local section = state.items["p1x3q8"]
    assert.is_nil(section:text_path())
    assert.is_nil(section:notes_path())
    assert.is_nil(section:display_number())
  end)

  describe("mutations", function()
    local temp_dir

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
        local section = Section.create(state, "Part 3", state.manuscript.items)

        assert.is_not_nil(section)
        assert.equals("Part 3", section.name)
        assert.equals("section", section.kind)

        -- Verify persistence
        state:load(temp_dir)
        assert.is_not_nil(state.items[section.id])
      end)
    end)

    describe("update", function()
      it("updates the section name", function()
        local section = state.items["p1x3q8"]
        local updated = section:update(state, { name = "Renamed Part" })

        assert.equals("Renamed Part", updated.name)

        -- Verify persistence
        state:load(temp_dir)
        assert.equals("Renamed Part", state.items["p1x3q8"].name)
      end)
    end)

    describe("destroy", function()
      it("removes the section and promotes its entries to parent", function()
        local section = state.items["p1x3q8"]
        local child_count = #section.items
        local original_root_count = #state.manuscript.items

        local result = section:destroy(state)

        assert.is_true(result)
        assert.is_nil(state.items["p1x3q8"])

        -- Children should be promoted to root level
        -- Original: 4 items (2 sections + 2 unsectioned)
        -- After: 4 - 1 section + 4 children = 7 items
        assert.equals(original_root_count - 1 + child_count, #state.manuscript.items)

        -- Verify persistence
        state:load(temp_dir)
        assert.is_nil(state.items["p1x3q8"])
        -- Children should still exist
        assert.is_not_nil(state.items["chap1a"])
      end)
    end)
  end)
end)
