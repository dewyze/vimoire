local assert = require("luassert")
local helpers = require("tests.helpers")
local Path = require("plenary.path")

describe("scaffold", function()
  local scaffold
  local temp_dir

  before_each(function()
    package.loaded["vimoire.scaffold"] = nil
    scaffold = require("vimoire.scaffold")
    temp_dir = helpers.temp_dir()
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
  end)

  describe("create", function()
    it("creates book.yml with title", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "My First Novel")

      local book_path = Path:new(project_dir, "book.yml")
      assert.is_true(book_path:exists())

      local content = book_path:read()
      assert.matches('title: "My First Novel"', content)
    end)

    it("creates manuscript.json", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "My First Novel")

      local manuscript_path = Path:new(project_dir, "manuscript.json")
      assert.is_true(manuscript_path:exists())
    end)

    it("creates starter entries", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      local content = vim.json.decode(Path:new(project_dir, "manuscript.json"):read())
      assert.equals(2, #content.items)
      assert.equals("page", content.items[1].kind)
      assert.equals("Dedication", content.items[1].name)
      assert.equals("chapter", content.items[2].kind)
      assert.equals("Chapter 1", content.items[2].name)
    end)

    it("creates starter planning items", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      local content = vim.json.decode(Path:new(project_dir, "manuscript.json"):read())
      assert.equals(1, #content.characters)
      assert.equals("Protagonist", content.characters[1].name)
      assert.are.same({}, content.settings)
      assert.equals(1, #content.reference)
      assert.equals("Research Notes", content.reference[1].name)
    end)

    it("creates entry files with content", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      local content = vim.json.decode(Path:new(project_dir, "manuscript.json"):read())
      local dedication_id = content.items[1].id
      local chapter_id = content.items[2].id

      assert.is_true(Path:new(project_dir, "entries", dedication_id, "prose.md"):exists())
      assert.is_true(Path:new(project_dir, "entries", chapter_id, "prose.md"):exists())
    end)

    it("creates planning files with content", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      local content = vim.json.decode(Path:new(project_dir, "manuscript.json"):read())
      local protagonist_id = content.characters[1].id
      local research_id = content.reference[1].id

      assert.is_true(Path:new(project_dir, "planning", protagonist_id, "text.md"):exists())
      assert.is_true(Path:new(project_dir, "planning", research_id, "text.md"):exists())
    end)

    it("generates unique manuscript id", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      local content = vim.json.decode(Path:new(project_dir, "manuscript.json"):read())
      assert.is_not_nil(content.id)
      assert.equals(6, #content.id)
    end)

    it("creates entries directory", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      assert.is_true(Path:new(project_dir, "entries"):exists())
    end)

    it("creates planning subdirectories", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      assert.is_true(Path:new(project_dir, "planning", "characters"):exists())
      assert.is_true(Path:new(project_dir, "planning", "settings"):exists())
      assert.is_true(Path:new(project_dir, "planning", "reference"):exists())
    end)

    it("creates spell directory", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      assert.is_true(Path:new(project_dir, "spell"):exists())
    end)

    it("creates assets/images directory with .gitkeep", function()
      local project_dir = temp_dir .. "/my-book"

      scaffold.create(project_dir, "Test Book")

      assert.is_true(Path:new(project_dir, "assets", "images"):exists())
      assert.is_true(Path:new(project_dir, "assets", "images", ".gitkeep"):exists())
    end)

    it("returns the project path", function()
      local project_dir = temp_dir .. "/my-book"

      local result = scaffold.create(project_dir, "Test Book")

      assert.equals(project_dir, result)
    end)
  end)
end)
