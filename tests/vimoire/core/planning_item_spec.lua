local assert = require("luassert")
local helpers = require("tests.helpers")

describe("PlanningItem", function()
  local PlanningItem = require("vimoire.core.planning_item")
  local state = require("vimoire.state")
  local temp_dir
  local planning_base

  before_each(function()
    temp_dir = helpers.create_temp_fixture("tests/fixtures/standard")
    state:load(temp_dir)
    planning_base = temp_dir .. "/planning"
  end)

  after_each(function()
    helpers.cleanup_temp_fixture(temp_dir)
    helpers.reset_state()
  end)

  it("holds planning item metadata", function()
    local data = { id = "char1", name = "Gerald", file = "gerald.md" }
    local item = PlanningItem.new(data, "characters", planning_base .. "/characters")

    assert.equals(item.id, "char1")
    assert.equals(item.name, "Gerald")
    assert.equals(item.file, "gerald.md")
    assert.equals(item.type, "characters")
  end)

  it("resolves full path", function()
    local data = { id = "char1", name = "Gerald", file = "gerald.md" }
    local item = PlanningItem.new(data, "characters", planning_base .. "/characters")

    assert.equals(item:text_path(), planning_base .. "/characters/gerald.md")
  end)

  describe("mutations", function()
    describe("create", function()
      it("creates a new character", function()
        local parent_items = state.manuscript.characters
        local base_path = planning_base .. "/characters"
        local item = PlanningItem.create_character(state, "New Character", parent_items, base_path)

        assert.is_not_nil(item)
        assert.equals(item.name, "New Character")
        assert.equals(item.type, "characters")
        assert.equals(item.file, "new_character.md")

        -- Check file exists
        local path = require("plenary.path")
        assert.is_true(path:new(item:text_path()):exists())

        -- Check added to manuscript
        local found = false
        for _, c in ipairs(state.manuscript.characters) do
          if c.id == item.id then
            found = true
            break
          end
        end
        assert.is_true(found)
      end)

      it("creates a new setting", function()
        local parent_items = state.manuscript.settings
        local base_path = planning_base .. "/settings"
        local item = PlanningItem.create_setting(state, "New Place", parent_items, base_path)

        assert.equals(item.type, "settings")
        assert.equals(item.file, "new_place.md")
      end)

      it("creates a new reference doc", function()
        local parent_items = state.manuscript.reference
        local base_path = planning_base .. "/reference"
        local item = PlanningItem.create_reference(state, "New Research", parent_items, base_path)

        assert.equals(item.type, "reference")
        assert.equals(item.file, "new_research.md")
      end)

      it("creates item in subfolder", function()
        -- Find the bread subfolder's items array
        local subfolder = state.items["brdref"]
        local subfolder_data = nil
        for _, item in ipairs(state.manuscript.reference) do
          if item.id == "brdref" then
            subfolder_data = item
            break
          end
        end

        local item = PlanningItem.create_reference(state, "New Doc", subfolder_data.items, subfolder:dir_path())

        assert.equals(item.file, "new_doc.md")
        assert.equals(item:text_path(), subfolder:dir_path() .. "/new_doc.md")
      end)
    end)

    describe("update", function()
      it("updates the item name", function()
        local item = state.items["char1"]
        local old_name = item.name

        item:update(state, { name = "Gerald the Great" })

        assert.equals(item.name, "Gerald the Great")
        assert.not_equals(item.name, old_name)
      end)
    end)

    describe("destroy", function()
      it("removes the planning item", function()
        local item = state.items["char1"]
        local item_id = item.id
        local file_path = item:text_path()

        item:destroy(state)

        -- Check removed from manuscript
        for _, c in ipairs(state.manuscript.characters) do
          assert.not_equals(c.id, item_id)
        end

        -- Check file removed
        local path = require("plenary.path")
        assert.is_false(path:new(file_path):exists())
      end)
    end)
  end)
end)
