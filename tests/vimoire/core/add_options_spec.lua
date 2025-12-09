local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")
local add_options = require("vimoire.core.add_options")

describe("add_options", function()
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

  describe("item:add_options()", function()
    it("returns SECTION, CHAPTER, PAGE, CANCEL for manuscript", function()
      local manuscript = state.items["manuscript"]

      local options = manuscript:add_options()

      assert.equals(4, #options)
      assert.equals(add_options.SECTION, options[1])
      assert.equals(add_options.CHAPTER, options[2])
      assert.equals(add_options.PAGE, options[3])
      assert.equals(add_options.CANCEL, options[4])
    end)

    it("returns CHAPTER, PAGE, CANCEL for section", function()
      local section = state.items["p1x3q8"]

      local options = section:add_options()

      assert.equals(3, #options)
      assert.equals(add_options.CHAPTER, options[1])
      assert.equals(add_options.PAGE, options[2])
      assert.equals(add_options.CANCEL, options[3])
    end)

    it("returns CHAPTER, PAGE, CANCEL for chapter (sibling)", function()
      local chapter = state.items["chap1a"]

      local options = chapter:add_options()

      assert.equals(3, #options)
      assert.equals(add_options.CHAPTER, options[1])
      assert.equals(add_options.PAGE, options[2])
      assert.equals(add_options.CANCEL, options[3])
    end)

    it("returns CHAPTER, PAGE, CANCEL for page (sibling)", function()
      local page = state.items["intrlud"]

      local options = page:add_options()

      assert.equals(3, #options)
      assert.equals(add_options.CHAPTER, options[1])
      assert.equals(add_options.PAGE, options[2])
      assert.equals(add_options.CANCEL, options[3])
    end)

    it("returns PLANNING_ITEM, CANCEL for characters folder", function()
      local characters = state.items["characters"]

      local options = characters:add_options()

      assert.equals(2, #options)
      assert.equals(add_options.PLANNING_ITEM, options[1])
      assert.equals(add_options.CANCEL, options[2])
    end)

    it("returns PLANNING_ITEM, CANCEL for settings folder", function()
      local settings = state.items["settings"]

      local options = settings:add_options()

      assert.equals(2, #options)
      assert.equals(add_options.PLANNING_ITEM, options[1])
      assert.equals(add_options.CANCEL, options[2])
    end)

    it("returns PLANNING_ITEM, SUBFOLDER, CANCEL for reference folder", function()
      local reference = state.items["reference"]

      local options = reference:add_options()

      assert.equals(3, #options)
      assert.equals(add_options.PLANNING_ITEM, options[1])
      assert.equals(add_options.SUBFOLDER, options[2])
      assert.equals(add_options.CANCEL, options[3])
    end)

    it("returns PLANNING_ITEM, CANCEL for planning item (sibling)", function()
      local item = state.items["char1"]

      local options = item:add_options()

      assert.equals(2, #options)
      assert.equals(add_options.PLANNING_ITEM, options[1])
      assert.equals(add_options.CANCEL, options[2])
    end)

    it("returns nil for planning folder", function()
      local planning = state.items["planning"]

      local options = planning:add_options()

      assert.is_nil(options)
    end)
  end)

  describe("item:add_index()", function()
    it("returns 1 for manuscript", function()
      local manuscript = state.items["manuscript"]

      assert.equals(1, manuscript:add_index())
    end)

    it("returns 1 for section", function()
      local section = state.items["p1x3q8"]

      assert.equals(1, section:add_index())
    end)

    it("returns index + 1 for chapter (after self)", function()
      local chapter = state.items["chap1a"]
      -- chap1a is at index 2 in Part 1 (after part1tp page)

      assert.equals(3, chapter:add_index())
    end)

    it("returns 1 for characters folder", function()
      local characters = state.items["characters"]

      assert.equals(1, characters:add_index())
    end)

    it("returns index + 1 for planning item (after self)", function()
      local item = state.items["char1"]
      -- char1 is at index 1 in characters

      assert.equals(2, item:add_index())
    end)
  end)

  describe("item:add_parent_items()", function()
    it("returns manuscript.items for manuscript", function()
      local manuscript = state.items["manuscript"]

      local parent_items = manuscript:add_parent_items()

      assert.equals(state.manuscript.items, parent_items)
    end)

    it("returns section.items for section", function()
      local section = state.items["p1x3q8"]

      local parent_items = section:add_parent_items()

      assert.equals(section.items, parent_items)
    end)

    it("returns item.parent_items for chapter (sibling)", function()
      local chapter = state.items["chap1a"]

      local parent_items = chapter:add_parent_items()

      assert.equals(chapter.parent_items, parent_items)
    end)

    it("returns manuscript.characters for characters folder", function()
      local characters = state.items["characters"]

      local parent_items = characters:add_parent_items()

      assert.equals(state.manuscript.characters, parent_items)
    end)

    it("returns item.parent_items for planning item (sibling)", function()
      local item = state.items["char1"]

      local parent_items = item:add_parent_items()

      assert.equals(item.parent_items, parent_items)
    end)
  end)

  describe("labels", function()
    it("returns array of label strings", function()
      local manuscript = state.items["manuscript"]
      local options = manuscript:add_options()

      local labels = add_options.labels(options)

      assert.equals(4, #labels)
      assert.equals("Section", labels[1])
      assert.equals("Chapter", labels[2])
      assert.equals("Page", labels[3])
      assert.equals("Cancel", labels[4])
    end)
  end)

  describe("find_by_label", function()
    it("finds option by its label", function()
      local manuscript = state.items["manuscript"]
      local options = manuscript:add_options()

      local found = add_options.find_by_label(options, "Chapter")

      assert.equals(add_options.CHAPTER, found)
    end)

    it("returns nil for unknown label", function()
      local manuscript = state.items["manuscript"]
      local options = manuscript:add_options()

      local found = add_options.find_by_label(options, "Unknown")

      assert.is_nil(found)
    end)
  end)
end)
