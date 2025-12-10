local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")
local movement = require("vimoire.core.movement")

describe("Movement", function()
  local temp_dir
  local fixture_path = "tests/fixtures/standard"

  before_each(function()
    temp_dir = helpers.temp_copy(fixture_path)
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  describe("move_up", function()
    it("swaps with previous item within array", function()
      -- chap1b is at index 2 in Part 1, chap1a at index 1
      local result = movement.move_up(state, "chap1b")

      assert.is_true(result)
      local section_items = state.manuscript.items[1].items
      assert.equals("chap1b", section_items[2].id)
      assert.equals("chap1a", section_items[3].id)
    end)

    it("pops out before section when at top of section", function()
      -- part1tp is first in Part 1, should pop out before Part 1
      local result = movement.move_up(state, "part1tp")

      assert.is_true(result)
      assert.equals("part1tp", state.manuscript.items[1].id)
      assert.equals("p1x3q8", state.manuscript.items[2].id)
    end)

    it("enters section at bottom when previous item is section", function()
      -- intrlud is after Part 1, moving up should enter Part 1 at bottom
      local result = movement.move_up(state, "intrlud")

      assert.is_true(result)
      local section_items = state.manuscript.items[1].items
      assert.equals("intrlud", section_items[#section_items].id)
    end)

    it("returns false at root top", function()
      -- Part 1 section is first at root
      local result = movement.move_up(state, "p1x3q8")

      assert.is_false(result)
    end)
  end)

  describe("move_down", function()
    it("swaps with next item within array", function()
      -- chap1a is at index 2 in Part 1, chap1b at index 3
      local result = movement.move_down(state, "chap1a")

      assert.is_true(result)
      local section_items = state.manuscript.items[1].items
      assert.equals("chap1b", section_items[2].id)
      assert.equals("chap1a", section_items[3].id)
    end)

    it("pops out after section when at bottom of section", function()
      -- chap1c is last in Part 1, should pop out after Part 1
      local result = movement.move_down(state, "chap1c")

      assert.is_true(result)
      assert.equals("chap1c", state.manuscript.items[2].id)
      assert.equals("intrlud", state.manuscript.items[3].id)
    end)

    it("enters section at top when next item is section", function()
      -- intrlud is before Part 2, moving down should enter Part 2 at top
      local result = movement.move_down(state, "intrlud")

      assert.is_true(result)
      local section_items = state.manuscript.items[2].items
      assert.equals("intrlud", section_items[1].id)
    end)

    it("returns false at root bottom", function()
      -- appndxa is last at root
      local result = movement.move_down(state, "appndxa")

      assert.is_false(result)
    end)
  end)
end)
