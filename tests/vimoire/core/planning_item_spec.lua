local assert = require("luassert")
local helpers = require("tests.helpers")

describe("PlanningItem", function()
  local PlanningItem = require("vimoire.core.planning_item")
  local state = require("vimoire.state")
  local temp_dir

  before_each(function()
    temp_dir = helpers.create_temp_fixture("tests/fixtures/standard")
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup_temp_fixture(temp_dir)
    helpers.reset_state()
  end)

  it("holds planning item metadata", function()
    local data = { id = "char1", name = "Gerald", file = "planning/characters/gerald.md" }
    local item = PlanningItem.new(data, "characters", temp_dir)

    assert.equals(item.id, "char1")
    assert.equals(item.name, "Gerald")
    assert.equals(item.file, "planning/characters/gerald.md")
    assert.equals(item.type, "characters")
  end)

  it("resolves full path", function()
    local data = { id = "char1", name = "Gerald", file = "planning/characters/gerald.md" }
    local item = PlanningItem.new(data, "characters", temp_dir)

    assert.equals(item:full_path(), temp_dir .. "/planning/characters/gerald.md")
  end)

  describe("mutations", function()
    describe("create", function()
      it("creates a new character", function()
        local item = PlanningItem.create_character(state, "New Character")

        assert.is_not_nil(item)
        assert.equals(item.name, "New Character")
        assert.equals(item.type, "characters")
        assert.matches("planning/characters/", item.file)

        -- Check file exists
        local path = require("plenary.path")
        assert.is_true(path:new(item:full_path()):exists())

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
        local item = PlanningItem.create_setting(state, "New Place")

        assert.equals(item.type, "settings")
        assert.matches("planning/settings/", item.file)
      end)

      it("creates a new reference doc", function()
        local item = PlanningItem.create_reference(state, "New Research")

        assert.equals(item.type, "reference")
        assert.matches("planning/reference/", item.file)
      end)

      it("creates item in subfolder", function()
        local item = PlanningItem.create_reference(state, "New Doc", "bread")

        assert.matches("planning/reference/bread/", item.file)
      end)
    end)

    describe("update", function()
      it("updates the item name", function()
        local item = PlanningItem.new(state.manuscript.characters[1], "characters", temp_dir)
        local old_name = item.name

        item:update(state, { name = "Gerald the Great" })

        assert.equals(item.name, "Gerald the Great")
        assert.not_equals(item.name, old_name)
      end)
    end)

    describe("destroy", function()
      it("removes the planning item", function()
        local item = PlanningItem.new(state.manuscript.characters[1], "characters", temp_dir)
        local item_id = item.id
        local file_path = item:full_path()

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
