local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")
local delete_options = require("vimoire.core.delete_options")

describe("delete_options", function()
  local fixture_path = "tests/fixtures/standard"
  local temp_dir

  before_each(function()
    temp_dir = helpers.temp_copy(fixture_path)
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  describe("for_item", function()
    it("returns nil for immutable items", function()
      local manuscript = state.items["manuscript"]

      local result = delete_options.for_item(manuscript)

      assert.is_nil(result)
    end)

    it("returns choose for sections with children", function()
      local section = state.items["p1x3q8"]
      assert.is_true(#section.items > 0)

      local result = delete_options.for_item(section)

      assert.is_nil(result.confirm)
      assert.equals(2, #result.choose)
      assert.equals(delete_options.KEEP_CONTENTS, result.choose[1])
      assert.equals(delete_options.DELETE_WITH_CONTENTS, result.choose[2])
    end)

    it("returns confirm for items without children", function()
      local chapter = state.items["chap1a"]

      local result = delete_options.for_item(chapter)

      assert.is_nil(result.choose)
      assert.equals(delete_options.DELETE, result.confirm)
    end)

    it("returns confirm for empty sections", function()
      local ManuscriptSection = require("vimoire.core.manuscript_section")
      local section = ManuscriptSection.create(state, "Empty Section", state.manuscript.items, #state.manuscript.items + 1)

      local result = delete_options.for_item(section)

      assert.is_nil(result.choose)
      assert.equals(delete_options.DELETE, result.confirm)
    end)
  end)

  describe("labels", function()
    it("returns array of label strings", function()
      local section = state.items["p1x3q8"]
      local result = delete_options.for_item(section)

      local labels = delete_options.labels(result.choose, section)

      assert.equals(2, #labels)
      assert.equals("Delete 'Part 1', keep contents", labels[1])
      assert.equals("Delete 'Part 1' and contents", labels[2])
    end)
  end)

  describe("find_by_label", function()
    it("finds option by its label", function()
      local section = state.items["p1x3q8"]
      local result = delete_options.for_item(section)

      local found = delete_options.find_by_label(result.choose, "Delete 'Part 1', keep contents", section)

      assert.equals(delete_options.KEEP_CONTENTS, found)
    end)

    it("returns nil for unknown label", function()
      local section = state.items["p1x3q8"]
      local result = delete_options.for_item(section)

      local found = delete_options.find_by_label(result.choose, "Unknown", section)

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

end)
