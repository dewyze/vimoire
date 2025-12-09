local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")
local delete_options = require("vimoire.core.delete_options")

describe("delete_options", function()
  local fixture_path = "tests/fixtures/standard"
  local temp_dir

  before_each(function()
    temp_dir = helpers.create_temp_fixture(fixture_path)
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup_temp_fixture(temp_dir)
    helpers.reset_state()
  end)

  describe("options_for", function()
    it("returns nil for immutable items", function()
      local manuscript = state.items["manuscript"]

      local options = delete_options.options_for(manuscript)

      assert.is_nil(options)
    end)

    it("returns KEEP_CONTENTS, DELETE_WITH_CONTENTS, CANCEL for sections with children", function()
      local section = state.items["p1x3q8"]
      assert.is_true(#section.items > 0)

      local options = delete_options.options_for(section)

      assert.equals(3, #options)
      assert.equals(delete_options.KEEP_CONTENTS, options[1])
      assert.equals(delete_options.DELETE_WITH_CONTENTS, options[2])
      assert.equals(delete_options.CANCEL, options[3])
    end)

    it("returns DELETE, CANCEL for items without children", function()
      local chapter = state.items["chap1a"]

      local options = delete_options.options_for(chapter)

      assert.equals(2, #options)
      assert.equals(delete_options.DELETE, options[1])
      assert.equals(delete_options.CANCEL, options[2])
    end)

    it("returns DELETE, CANCEL for empty sections", function()
      local Section = require("vimoire.core.section")
      local section = Section.create(state, "Empty Section", state.manuscript.items, #state.manuscript.items + 1)

      local options = delete_options.options_for(section)

      assert.equals(2, #options)
      assert.equals(delete_options.DELETE, options[1])
      assert.equals(delete_options.CANCEL, options[2])
    end)
  end)

  describe("labels", function()
    it("returns array of label strings", function()
      local section = state.items["p1x3q8"]
      local options = delete_options.options_for(section)

      local labels = delete_options.labels(options, section)

      assert.equals(3, #labels)
      assert.equals("Delete 'Part 1', keep contents", labels[1])
      assert.equals("Delete 'Part 1' and contents", labels[2])
      assert.equals("Cancel", labels[3])
    end)
  end)

  describe("find_by_label", function()
    it("finds option by its label", function()
      local section = state.items["p1x3q8"]
      local options = delete_options.options_for(section)

      local found = delete_options.find_by_label(options, "Cancel", section)

      assert.equals(delete_options.CANCEL, found)
    end)

    it("returns nil for unknown label", function()
      local section = state.items["p1x3q8"]
      local options = delete_options.options_for(section)

      local found = delete_options.find_by_label(options, "Unknown", section)

      assert.is_nil(found)
    end)
  end)

  describe("DELETE", function()
    it("destroys the item", function()
      local chapter = state.items["chap1a"]

      local result = delete_options.DELETE.execute(chapter, state)

      assert.is_true(result)
      assert.is_nil(state.items["chap1a"])
    end)
  end)

  describe("KEEP_CONTENTS", function()
    it("promotes children and destroys the section", function()
      local section = state.items["p1x3q8"]
      local child_ids = {}
      for _, child in ipairs(section.items) do
        table.insert(child_ids, child.id)
      end
      local original_root_count = #state.manuscript.items

      local result = delete_options.KEEP_CONTENTS.execute(section, state)

      assert.is_true(result)
      assert.is_nil(state.items["p1x3q8"])
      -- Children promoted to root
      for _, id in ipairs(child_ids) do
        assert.is_not_nil(state.items[id])
      end
      -- Root count increased by children minus the section
      assert.equals(original_root_count - 1 + #child_ids, #state.manuscript.items)
    end)
  end)

  describe("DELETE_WITH_CONTENTS", function()
    it("destroys children and the section", function()
      local section = state.items["p1x3q8"]
      local child_ids = {}
      for _, child in ipairs(section.items) do
        table.insert(child_ids, child.id)
      end

      local result = delete_options.DELETE_WITH_CONTENTS.execute(section, state)

      assert.is_true(result)
      assert.is_nil(state.items["p1x3q8"])
      -- Children gone
      for _, id in ipairs(child_ids) do
        assert.is_nil(state.items[id])
      end
    end)
  end)

  describe("CANCEL", function()
    it("returns false and does nothing", function()
      local chapter = state.items["chap1a"]

      local result = delete_options.CANCEL.execute(chapter, state)

      assert.is_false(result)
      assert.is_not_nil(state.items["chap1a"])
    end)
  end)
end)
