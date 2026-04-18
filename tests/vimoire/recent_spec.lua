local assert = require("luassert")
local helpers = require("tests.helpers")
local preferences = require("vimoire.preferences")
local recent = require("vimoire.recent")

describe("recent", function()
  local prefs_dir

  before_each(function()
    prefs_dir = helpers.temp_dir()
    preferences.set_directory(prefs_dir)
  end)

  after_each(function()
    preferences.reset_directory()
    helpers.cleanup(prefs_dir)
  end)

  describe("list", function()
    it("returns empty table when no recent file exists", function()
      local projects = recent.list()

      assert.are.same({}, projects)
    end)

    it("returns projects from preferences file", function()
      local project_dir = helpers.temp_copy("tests/fixtures/standard")
      local prefs_data = {
        recent_projects = {
          { path = project_dir, title = "Test Book", last_opened = 1000 },
        },
      }
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode(prefs_data))
      preferences.reset_directory()
      preferences.set_directory(prefs_dir)

      local projects = recent.list()

      assert.equals(1, #projects)
      assert.equals("Test Book", projects[1].title)
      assert.equals(project_dir, projects[1].path)

      helpers.cleanup(project_dir)
    end)

    it("prunes non-existent paths", function()
      local valid_dir = helpers.temp_copy("tests/fixtures/standard")
      local prefs_data = {
        recent_projects = {
          { path = valid_dir, title = "Valid Book", last_opened = 2000 },
          { path = "/nonexistent/path", title = "Gone Book", last_opened = 1000 },
        },
      }
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode(prefs_data))
      preferences.reset_directory()
      preferences.set_directory(prefs_dir)

      local projects = recent.list()

      assert.equals(1, #projects)
      assert.equals("Valid Book", projects[1].title)

      helpers.cleanup(valid_dir)
    end)
  end)

  describe("add", function()
    it("creates preferences directory if it doesn't exist", function()
      helpers.cleanup(prefs_dir)
      prefs_dir = helpers.temp_dir()
      helpers.cleanup(prefs_dir) -- Remove it so add() has to create it
      preferences.set_directory(prefs_dir)

      local project_dir = helpers.temp_copy("tests/fixtures/standard")
      recent.add(project_dir, "New Book")

      local projects = recent.list()
      assert.equals(1, #projects)

      helpers.cleanup(project_dir)
    end)

    it("adds project to front of list", function()
      local dir1 = helpers.temp_copy("tests/fixtures/standard")
      local dir2 = helpers.temp_copy("tests/fixtures/flat")

      recent.add(dir1, "First")
      recent.add(dir2, "Second")

      local projects = recent.list()
      assert.equals(2, #projects)
      assert.equals("Second", projects[1].title)
      assert.equals("First", projects[2].title)

      helpers.cleanup(dir1)
      helpers.cleanup(dir2)
    end)

    it("moves existing project to front", function()
      local dir1 = helpers.temp_copy("tests/fixtures/standard")
      local dir2 = helpers.temp_copy("tests/fixtures/flat")

      recent.add(dir1, "First")
      recent.add(dir2, "Second")
      recent.add(dir1, "First Updated")

      local projects = recent.list()
      assert.equals(2, #projects)
      assert.equals("First Updated", projects[1].title)
      assert.equals("Second", projects[2].title)

      helpers.cleanup(dir1)
      helpers.cleanup(dir2)
    end)

    it("limits to 10 projects", function()
      local dirs = {}
      for i = 1, 12 do
        dirs[i] = helpers.temp_copy("tests/fixtures/standard")
        recent.add(dirs[i], "Book " .. i)
      end

      local projects = recent.list()
      assert.equals(10, #projects)
      assert.equals("Book 12", projects[1].title)
      assert.equals("Book 3", projects[10].title)

      for _, dir in ipairs(dirs) do
        helpers.cleanup(dir)
      end
    end)

    it("normalizes path (removes trailing slash)", function()
      local dir = helpers.temp_copy("tests/fixtures/standard")

      recent.add(dir .. "/", "Test")
      recent.add(dir, "Test Again")

      local projects = recent.list()
      assert.equals(1, #projects)
      assert.equals("Test Again", projects[1].title)

      helpers.cleanup(dir)
    end)
  end)
end)
