local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("Entry", function()
  local Entry = require("vimoire.core.entry")
  local Document = require("vimoire.core.document")

  describe("factory", function()
    it("builds Document for kind=chapter", function()
      local entry = Entry.build({ id = "ch1", kind = "chapter", name = "Test" }, "/root")
      assert.equals("chapter", entry.kind)
      assert.is_not_nil(entry.text_path)
    end)

    it("builds Document for kind=page", function()
      local entry = Entry.build({ id = "p1", kind = "page", name = "Test" }, "/root")
      assert.equals("page", entry.kind)
    end)

    it("builds Section for kind=section", function()
      local entry = Entry.build({ id = "s1", kind = "section", name = "Part 1", items = {} }, "/root")
      assert.equals("section", entry.kind)
      assert.is_nil(entry:text_path())
    end)
  end)

  describe("Document as chapter", function()
    it("holds chapter metadata", function()
      local doc = Document.new({ id = "ch1", kind = "chapter", name = "Test" }, "/root", { base = "entries" })
      assert.equals("ch1", doc.id)
      assert.equals("chapter", doc.kind)
      assert.equals("Test", doc.name)
    end)

    it("returns text_path", function()
      local doc = Document.new({ id = "abc123", kind = "chapter", name = "Test" }, "/some/root", { base = "entries" })
      assert.equals("/some/root/entries/abc123/text.md", doc:text_path())
    end)

    it("returns notes_path", function()
      local doc = Document.new({ id = "abc123", kind = "chapter", name = "Test" }, "/some/root", { base = "entries", extras = true })
      assert.equals("/some/root/entries/abc123/notes.md", doc:notes_path())
    end)

    it("returns display_number from chapter_index", function()
      local doc = Document.new({ id = "ch1", kind = "chapter", name = "Test" }, "/root", { base = "entries" })
      doc.chapter_index = 3
      assert.equals("3", doc:display_number())
    end)
  end)

  describe("Document as page", function()
    it("holds page metadata", function()
      local doc = Document.new({ id = "p1", kind = "page", name = "Interlude" }, "/root", { base = "entries" })
      assert.equals("p1", doc.id)
      assert.equals("page", doc.kind)
    end)

    it("returns nil for display_number without chapter_index", function()
      local doc = Document.new({ id = "p1", kind = "page", name = "Test" }, "/root", { base = "entries" })
      assert.is_nil(doc:display_number())
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

    describe("Document.create", function()
      it("creates a new chapter in section", function()
        local section_data = state.manuscript.items[1]

        local doc = Document.create(state, "New Chapter", section_data.items, #section_data.items + 1, {
          kind = "chapter",
          base = "entries",
          extras = true,
        })

        assert.is_not_nil(doc)
        assert.equals("New Chapter", doc.name)
        assert.equals("chapter", doc.kind)

        -- Verify file created
        local entry_dir = Path:new(temp_dir, "entries", doc.id)
        assert.is_true(entry_dir:exists())

        -- Verify persistence
        state:load(temp_dir)
        assert.is_not_nil(state.items[doc.id])
      end)

      it("creates a new chapter at root level", function()
        local doc = Document.create(state, "Root Chapter", state.manuscript.items, #state.manuscript.items + 1, {
          kind = "chapter",
          base = "entries",
        })

        assert.is_not_nil(doc)

        -- Verify persistence
        state:load(temp_dir)
        assert.is_not_nil(state.items[doc.id])
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
    end)
  end)
end)
