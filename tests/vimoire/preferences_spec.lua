local assert = require("luassert")
local helpers = require("tests.helpers")
local preferences = require("vimoire.preferences")

describe("preferences", function()
  local prefs_dir

  before_each(function()
    prefs_dir = helpers.temp_dir()
    preferences.set_directory(prefs_dir)
  end)

  after_each(function()
    preferences.reset_directory()
    helpers.cleanup(prefs_dir)
  end)

  describe("get", function()
    it("returns nil for missing key when no file exists", function()
      assert.is_nil(preferences.get("colorscheme"))
    end)

    it("returns value from preferences file", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "parchment",
      }))
      preferences.reset_directory()
      preferences.set_directory(prefs_dir)

      assert.equals("parchment", preferences.get("colorscheme"))
    end)

    it("returns nil for missing key when file exists", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "parchment",
      }))
      preferences.reset_directory()
      preferences.set_directory(prefs_dir)

      assert.is_nil(preferences.get("nonexistent"))
    end)
  end)

  describe("set", function()
    it("creates preferences file if it doesn't exist", function()
      preferences.set("colorscheme", "umbra")

      local content = helpers.read_file(prefs_dir .. "/preferences.json")
      local data = vim.json.decode(content)
      assert.equals("umbra", data.colorscheme)
    end)

    it("updates existing value", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "inkwell",
      }))
      preferences.reset_directory()
      preferences.set_directory(prefs_dir)

      preferences.set("colorscheme", "lumen")

      local content = helpers.read_file(prefs_dir .. "/preferences.json")
      local data = vim.json.decode(content)
      assert.equals("lumen", data.colorscheme)
    end)

    it("preserves other keys when updating", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "inkwell",
        other_setting = "preserved",
      }))
      preferences.reset_directory()
      preferences.set_directory(prefs_dir)

      preferences.set("colorscheme", "vellum")

      local content = helpers.read_file(prefs_dir .. "/preferences.json")
      local data = vim.json.decode(content)
      assert.equals("vellum", data.colorscheme)
      assert.equals("preserved", data.other_setting)
    end)

    it("updates cached value for subsequent get calls", function()
      preferences.set("colorscheme", "parchment")

      assert.equals("parchment", preferences.get("colorscheme"))
    end)
  end)
end)
