local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")
local rename = require("vimoire.core.rename")

describe("rename", function()
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

  describe("validate", function()
    it("rejects empty string", function()
      local chapter = state.items["chap1a"]

      local ok, err = rename.validate("", chapter)

      assert.is_false(ok)
      assert.equals("Name cannot be empty", err)
    end)

    it("rejects whitespace-only string", function()
      local chapter = state.items["chap1a"]

      local ok, err = rename.validate("   ", chapter)

      assert.is_false(ok)
      assert.equals("Name cannot be empty", err)
    end)

    it("rejects nil", function()
      local chapter = state.items["chap1a"]

      local ok, err = rename.validate(nil, chapter)

      assert.is_false(ok)
      assert.equals("Name cannot be empty", err)
    end)

    it("rejects duplicate sibling name", function()
      local chapter_a = state.items["chap1a"]
      local chapter_b = state.items["chap1b"]
      chapter_b:update(state, { name = "Existing Name" })

      local ok, err = rename.validate("Existing Name", chapter_a)

      assert.is_false(ok)
      assert.equals("Name already exists", err)
    end)

    it("allows same name (no-op rename)", function()
      local chapter = state.items["chap1a"]
      chapter:update(state, { name = "Current Name" })

      local ok, err = rename.validate("Current Name", chapter)

      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("allows valid new name", function()
      local chapter = state.items["chap1a"]

      local ok, err = rename.validate("A New Beginning", chapter)

      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("rejects duplicate in sections", function()
      local section_1 = state.items["p1x3q8"]
      local section_2 = state.items["p2y5r4"]
      section_2:update(state, { name = "Existing Section" })

      local ok, err = rename.validate("Existing Section", section_1)

      assert.is_false(ok)
      assert.equals("Name already exists", err)
    end)
  end)

  describe("execute", function()
    it("returns false with error for invalid name", function()
      local chapter = state.items["chap1a"]

      local ok, err = rename.execute(chapter, state, "")

      assert.is_false(ok)
      assert.equals("Name cannot be empty", err)
    end)

    it("updates item name", function()
      local chapter = state.items["chap1a"]

      local ok = rename.execute(chapter, state, "New Chapter Name")

      assert.is_true(ok)
      assert.equals("New Chapter Name", state.items["chap1a"].name)
    end)

    it("persists to manuscript", function()
      local chapter = state.items["chap1a"]

      rename.execute(chapter, state, "Persisted Name")

      -- Reload and verify
      state:load(temp_dir)
      assert.equals("Persisted Name", state.items["chap1a"].name)
    end)

    it("returns false for immutable items", function()
      local manuscript = state.items["manuscript"]

      local ok, err = rename.execute(manuscript, state, "New Title")

      assert.is_false(ok)
      assert.equals("Cannot rename this item", err)
    end)
  end)
end)
