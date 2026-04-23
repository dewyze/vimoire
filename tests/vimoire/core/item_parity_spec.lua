local assert = require("luassert")

local Item = require("vimoire.core.item")
local Chapter = require("vimoire.core.chapter")
local Page = require("vimoire.core.page")
local PlanningItem = require("vimoire.core.planning_item")
local ManuscriptSection = require("vimoire.core.manuscript_section")
local PlanningSection = require("vimoire.core.planning_section")

describe("Item parity with per-kind classes", function()
  local root = "/some/root"

  local function attach_siblings(obj, siblings)
    obj.parent_items = siblings
  end

  local function compare_document(old, new)
    assert.equals(old:base(), new:base(), "base")
    assert.equals(old:extras(), new:extras(), "extras")
    assert.equals(old:category(), new:category(), "category")
    assert.equals(old:numbered(), new:numbered(), "numbered")
    assert.equals(old:action(), new:action(), "action")
    assert.equals(old:dir_path(), new:dir_path(), "dir_path")
    assert.equals(old:text_path(), new:text_path(), "text_path")
    assert.equals(old:notes_path(), new:notes_path(), "notes_path")
    assert.equals(old:display_number(), new:display_number(), "display_number")
    assert.equals(old:display_name(), new:display_name(), "display_name")
    assert.are.same(old:add_options(), new:add_options(), "add_options")
    assert.are.same(old:add_parent_items(), new:add_parent_items(), "add_parent_items")
    assert.equals(old:add_index(), new:add_index(), "add_index")
  end

  local function compare_container(old, new)
    assert.equals(old:action(), new:action(), "action")
    assert.equals(old:text_path(), new:text_path(), "text_path")
    assert.equals(old:notes_path(), new:notes_path(), "notes_path")
    assert.equals(old:display_number(), new:display_number(), "display_number")
    assert.equals(old:display_name(), new:display_name(), "display_name")
    assert.equals(old:category(), new:category(), "category")
    assert.are.same(old:add_options(), new:add_options(), "add_options")
    assert.are.same(old:add_parent_items(), new:add_parent_items(), "add_parent_items")
    assert.equals(old:add_index(), new:add_index(), "add_index")
  end

  describe("chapter", function()
    local function make_data()
      return { id = "abc123", kind = "chapter", name = "The Beginning" }
    end

    it("matches Chapter without chapter_index", function()
      local data = make_data()
      local siblings = { data }
      local old = Chapter.new(data, root)
      local new = Item.new("chapter", data, root)
      attach_siblings(old, siblings)
      attach_siblings(new, siblings)
      compare_document(old, new)
    end)

    it("matches Chapter with chapter_index", function()
      local data = make_data()
      local siblings = { data }
      local old = Chapter.new(data, root)
      local new = Item.new("chapter", data, root)
      attach_siblings(old, siblings)
      attach_siblings(new, siblings)
      old.chapter_index = 3
      new.chapter_index = 3
      compare_document(old, new)
    end)

    it("matches Chapter export_context", function()
      local data = make_data()
      local old = Chapter.new(data, root)
      local new = Item.new("chapter", data, root)
      old.chapter_index = 5
      new.chapter_index = 5
      assert.are.same(old:export_context(), new:export_context())
    end)

    it("matches Chapter display_name_for_path on notes.md", function()
      local data = make_data()
      local old = Chapter.new(data, root)
      local new = Item.new("chapter", data, root)
      old.chapter_index = 2
      new.chapter_index = 2
      local path = old:notes_path()
      assert.equals(old:display_name_for_path(path), new:display_name_for_path(path))
    end)
  end)

  describe("page", function()
    local function make_data()
      return { id = "pg001", kind = "page", name = "Interlude" }
    end

    it("matches Page on all accessors", function()
      local data = make_data()
      local siblings = { data }
      local old = Page.new(data, root)
      local new = Item.new("page", data, root)
      attach_siblings(old, siblings)
      attach_siblings(new, siblings)
      compare_document(old, new)
    end)

    it("matches Page export_context", function()
      local data = make_data()
      local old = Page.new(data, root)
      local new = Item.new("page", data, root)
      assert.are.same(old:export_context(), new:export_context())
    end)
  end)

  describe("planning_item", function()
    local function make_data()
      return { id = "plan42", kind = "planning_item", name = "Plot Note" }
    end

    it("matches PlanningItem on all accessors", function()
      local data = make_data()
      local siblings = { data }
      local old = PlanningItem.new(data, root)
      local new = Item.new("planning_item", data, root)
      attach_siblings(old, siblings)
      attach_siblings(new, siblings)
      compare_document(old, new)
    end)
  end)

  describe("section", function()
    local function make_data()
      return { id = "sec01", kind = "section", name = "Part One", items = {} }
    end

    it("matches ManuscriptSection on all accessors", function()
      local data = make_data()
      local siblings = { data }
      local old = ManuscriptSection.new(data, root)
      local new = Item.new("section", data, root)
      attach_siblings(old, siblings)
      attach_siblings(new, siblings)
      compare_container(old, new)
    end)
  end)

  describe("subfolder", function()
    local function make_data()
      return { id = "sub01", kind = "subfolder", name = "Characters", items = {} }
    end

    it("matches PlanningSection on all accessors", function()
      local data = make_data()
      local siblings = { data }
      local old = PlanningSection.new(data, root)
      local new = Item.new("subfolder", data, root)
      attach_siblings(old, siblings)
      attach_siblings(new, siblings)
      compare_container(old, new)
    end)
  end)
end)
