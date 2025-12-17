local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("Entry", function()
  local Entry = require("vimoire.core.entry")
  local Chapter = require("vimoire.core.chapter")
  local Page = require("vimoire.core.page")
  local ManuscriptSection = require("vimoire.core.manuscript_section")

  describe("factory", function()
    it("builds Chapter for kind=chapter", function()
      local entry = Entry.build({ id = "ch1", kind = "chapter", name = "Test" }, "/root")
      assert.equals("chapter", entry.kind)
      assert.is_not_nil(entry.text_path)
    end)

    it("builds Page for kind=page", function()
      local entry = Entry.build({ id = "p1", kind = "page", name = "Test" }, "/root")
      assert.equals("page", entry.kind)
    end)

    it("builds ManuscriptSection for kind=section", function()
      local entry = Entry.build({ id = "s1", kind = "section", name = "Part 1", items = {} }, "/root")
      assert.equals("section", entry.kind)
      assert.is_nil(entry:text_path())
    end)
  end)

  describe("Chapter", function()
    it("holds chapter metadata", function()
      local chapter = Chapter.new({ id = "ch1", kind = "chapter", name = "Test" }, "/root")
      assert.equals("ch1", chapter.id)
      assert.equals("chapter", chapter.kind)
      assert.equals("Test", chapter.name)
    end)

    it("returns text_path", function()
      local chapter = Chapter.new({ id = "abc123", kind = "chapter", name = "Test" }, "/some/root")
      assert.equals("/some/root/entries/abc123/prose.md", chapter:text_path())
    end)

    it("returns notes_path", function()
      local chapter = Chapter.new({ id = "abc123", kind = "chapter", name = "Test" }, "/some/root")
      assert.equals("/some/root/entries/abc123/notes.md", chapter:notes_path())
    end)

    it("returns display_number from chapter_index", function()
      local chapter = Chapter.new({ id = "ch1", kind = "chapter", name = "Test" }, "/root")
      chapter.chapter_index = 3
      assert.equals("3", chapter:display_number())
    end)
  end)

  describe("Page", function()
    it("holds page metadata", function()
      local page = Page.new({ id = "p1", kind = "page", name = "Interlude" }, "/root")
      assert.equals("p1", page.id)
      assert.equals("page", page.kind)
    end)

    it("returns nil for display_number without chapter_index", function()
      local page = Page.new({ id = "p1", kind = "page", name = "Test" }, "/root")
      assert.is_nil(page:display_number())
    end)
  end)

  describe("mutations", function()
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

    describe("Chapter.create", function()
      it("creates a new chapter in section", function()
        local section_data = state.manuscript.items[1]

        local chapter = Chapter.create(state, "New Chapter", section_data.items, #section_data.items + 1)

        assert.is_not_nil(chapter)
        assert.equals("New Chapter", chapter.name)
        assert.equals("chapter", chapter.kind)

        -- Verify file created
        local entry_dir = Path:new(temp_dir, "entries", chapter.id)
        assert.is_true(entry_dir:exists())

        -- Verify persistence
        state:load(temp_dir)
        assert.is_not_nil(state.items[chapter.id])
      end)

      it("creates a new chapter at root level", function()
        local chapter = Chapter.create(state, "Root Chapter", state.manuscript.items, #state.manuscript.items + 1)

        assert.is_not_nil(chapter)

        -- Verify persistence
        state:load(temp_dir)
        assert.is_not_nil(state.items[chapter.id])
      end)
    end)

    describe("update", function()
      it("updates the document name", function()
        local entry = state.items["chap1a"]
        local updated = entry:update(state, { name = "Renamed Chapter" })

        assert.equals("Renamed Chapter", updated.name)

        -- Verify persistence
        state:load(temp_dir)
        assert.equals("Renamed Chapter", state.items["chap1a"].name)
      end)
    end)

    describe("destroy", function()
      it("removes the document and its files", function()
        local entry = state.items["chap1a"]
        local entry_dir = Path:new(temp_dir, "entries", "chap1a")

        local result = entry:destroy(state)

        assert.is_true(result)
        assert.is_nil(state.items["chap1a"])
        assert.is_false(entry_dir:exists())

        -- Verify persistence
        state:load(temp_dir)
        assert.is_nil(state.items["chap1a"])
      end)

      it("moves notes.md to planning/orphaned_notes/ on delete", function()
        local entry = state.items["chap1a"]
        entry.chapter_index = 1
        local notes_path = Path:new(entry:notes_path())
        notes_path:write("My important notes", "w")

        entry:destroy(state)

        -- Reload state to get new planning item
        state:load(temp_dir)

        -- Should have created orphaned_notes with a planning item
        assert.is_not_nil(state.manuscript.orphaned_notes)
        assert.equals(1, #state.manuscript.orphaned_notes)
        assert.equals("1: The Day I Became Sentient", state.manuscript.orphaned_notes[1].name)

        -- Planning item should have the notes content
        local orphaned_item = state.items[state.manuscript.orphaned_notes[1].id]
        local content = Path:new(orphaned_item:text_path()):read()
        assert.equals("My important notes", content)
      end)

      it("does not create orphaned_notes if no notes exist", function()
        local entry = state.items["chap1a"]

        entry:destroy(state)

        local orphaned_dir = Path:new(temp_dir, "planning", "orphaned_notes")
        assert.is_false(orphaned_dir:exists())
      end)
    end)
  end)
end)
