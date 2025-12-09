local assert = require("luassert")
local helpers = require("tests.helpers")
local state = require("vimoire.state")

describe("Document", function()
  local Document = require("vimoire.core.document")
  local temp_dir

  before_each(function()
    temp_dir = helpers.create_temp_fixture("tests/fixtures/standard")
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup_temp_fixture(temp_dir)
    helpers.reset_state()
  end)

  describe("new", function()
    it("holds document metadata", function()
      local data = { id = "abc123", name = "Test Doc", kind = "chapter" }
      local doc = Document.new(data, temp_dir, { base = "entries", extras = true })

      assert.equals("abc123", doc.id)
      assert.equals("Test Doc", doc.name)
      assert.equals("chapter", doc.kind)
    end)

    it("stores icon and highlight from opts", function()
      local data = { id = "abc123", name = "Test", kind = "chapter" }
      local doc = Document.new(data, temp_dir, { base = "entries", icon = "X", highlight = "HL" })

      assert.equals("X", doc.icon)
      assert.equals("HL", doc.highlight)
    end)
  end)

  describe("text_path", function()
    it("returns path for entries", function()
      local data = { id = "abc123", name = "Test", kind = "chapter" }
      local doc = Document.new(data, temp_dir, { base = "entries" })

      assert.equals(temp_dir .. "/entries/abc123/text.md", doc:text_path())
    end)

    it("returns path for planning", function()
      local data = { id = "xyz789", name = "Test", kind = "planning_item" }
      local doc = Document.new(data, temp_dir, { base = "planning" })

      assert.equals(temp_dir .. "/planning/xyz789/text.md", doc:text_path())
    end)
  end)

  describe("notes_path", function()
    it("returns path when extras enabled", function()
      local data = { id = "abc123", name = "Test", kind = "chapter" }
      local doc = Document.new(data, temp_dir, { base = "entries", extras = true })

      assert.equals(temp_dir .. "/entries/abc123/notes.md", doc:notes_path())
    end)

    it("returns nil when extras disabled", function()
      local data = { id = "xyz789", name = "Test", kind = "planning_item" }
      local doc = Document.new(data, temp_dir, { base = "planning", extras = false })

      assert.is_nil(doc:notes_path())
    end)
  end)

  describe("display_name", function()
    it("returns numbered name for chapters", function()
      local doc = state.items["chap1a"]
      assert.matches("^%d+: ", doc:display_name())
    end)

    it("returns plain name for pages", function()
      local doc = state.items["intrlud"]
      assert.equals("Interlude: A Brief History of Crumbs", doc:display_name())
    end)
  end)

  describe("display_number", function()
    it("returns number for chapters", function()
      local doc = state.items["chap1a"]
      assert.is_not_nil(doc:display_number())
    end)

    it("returns nil for pages", function()
      local doc = state.items["intrlud"]
      assert.is_nil(doc:display_number())
    end)
  end)

  describe("mutations", function()
    describe("create", function()
      it("creates entry document", function()
        local doc = Document.create(state, "New Chapter", state.manuscript.items, #state.manuscript.items + 1, {
          kind = "chapter",
          base = "entries",
          extras = true,
        })

        assert.is_not_nil(doc)
        assert.equals("New Chapter", doc.name)
        assert.equals("chapter", doc.kind)

        local path = require("plenary.path")
        assert.is_true(path:new(doc:text_path()):exists())
      end)

      it("creates planning document", function()
        local doc = Document.create(state, "New Character", state.manuscript.characters, #state.manuscript.characters + 1, {
          kind = "planning_item",
          base = "planning",
          extras = false,
        })

        assert.is_not_nil(doc)
        assert.equals("New Character", doc.name)
        assert.equals("planning_item", doc.kind)

        local path = require("plenary.path")
        assert.is_true(path:new(doc:text_path()):exists())
      end)
    end)

    describe("update", function()
      it("updates the document name", function()
        local doc = state.items["chap1a"]

        doc:update(state, { name = "Renamed Chapter" })

        assert.equals("Renamed Chapter", doc.name)

        -- Verify persistence
        state:load(temp_dir)
        assert.equals("Renamed Chapter", state.items["chap1a"].name)
      end)
    end)

    describe("destroy", function()
      it("removes the document and its files", function()
        local doc = state.items["chap1a"]
        local doc_dir = temp_dir .. "/entries/chap1a"

        local result = doc:destroy(state)

        assert.is_true(result)
        assert.is_nil(state.items["chap1a"])

        local path = require("plenary.path")
        assert.is_false(path:new(doc_dir):exists())
      end)
    end)
  end)
end)
