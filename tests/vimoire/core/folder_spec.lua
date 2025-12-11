local assert = require("luassert")

describe("Folder", function()
  local Folder = require("vimoire.core.folder")

  describe("new", function()
    it("creates folder with id, name, kind", function()
      local folder = Folder.new("test", "Test Folder", "manuscript", {})
      assert.equals("test", folder.id)
      assert.equals("Test Folder", folder.name)
      assert.equals("manuscript", folder.kind)
    end)

    it("defaults items to empty table", function()
      local folder = Folder.new("test", "Test", "manuscript")
      assert.same({}, folder.items)
    end)

    it("accepts items array", function()
      local items = {{ id = "a" }, { id = "b" }}
      local folder = Folder.new("test", "Test", "manuscript", items)
      assert.same(items, folder.items)
    end)
  end)

  describe("interface", function()
    local folder

    before_each(function()
      folder = Folder.new("test", "Test Folder", "manuscript", {{ id = "child" }})
    end)

    it("display_name returns name", function()
      assert.equals("Test Folder", folder:display_name())
    end)

    it("text_path returns nil", function()
      assert.is_nil(folder:text_path())
    end)

    it("notes_path returns nil", function()
      assert.is_nil(folder:notes_path())
    end)

    it("add_parent_items returns items", function()
      assert.same({{ id = "child" }}, folder:add_parent_items())
    end)

    it("add_index returns 1", function()
      assert.equals(1, folder:add_index())
    end)
  end)
end)
