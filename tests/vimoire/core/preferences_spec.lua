local assert = require("luassert")
local helpers = require("tests.helpers")

describe("preferences", function()
  local preferences
  local prefs_dir
  local original_expand

  before_each(function()
    package.loaded["vimoire.core.preferences"] = nil

    prefs_dir = helpers.temp_dir()

    original_expand = vim.fn.expand
    vim.fn.expand = function(path)
      if path == "~/.vimoire" then
        return prefs_dir
      end
      return original_expand(path)
    end

    preferences = require("vimoire.core.preferences")
  end)

  after_each(function()
    vim.fn.expand = original_expand
    helpers.cleanup(prefs_dir)
  end)

  describe("get", function()
    it("returns nil for missing key when no file exists", function()
      assert.is_nil(preferences.get("colorscheme"))
    end)

    it("returns value from preferences file", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "vimoire-parchment",
      }))
      package.loaded["vimoire.core.preferences"] = nil
      preferences = require("vimoire.core.preferences")

      assert.equals("vimoire-parchment", preferences.get("colorscheme"))
    end)

    it("returns nil for missing key when file exists", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "vimoire-parchment",
      }))
      package.loaded["vimoire.core.preferences"] = nil
      preferences = require("vimoire.core.preferences")

      assert.is_nil(preferences.get("nonexistent"))
    end)
  end)

  describe("set", function()
    it("creates preferences file if it doesn't exist", function()
      preferences.set("colorscheme", "vimoire-umbra")

      local content = helpers.read_file(prefs_dir .. "/preferences.json")
      local data = vim.json.decode(content)
      assert.equals("vimoire-umbra", data.colorscheme)
    end)

    it("updates existing value", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "vimoire-inkwell",
      }))
      package.loaded["vimoire.core.preferences"] = nil
      preferences = require("vimoire.core.preferences")

      preferences.set("colorscheme", "vimoire-lumen")

      local content = helpers.read_file(prefs_dir .. "/preferences.json")
      local data = vim.json.decode(content)
      assert.equals("vimoire-lumen", data.colorscheme)
    end)

    it("preserves other keys when updating", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "vimoire-inkwell",
        other_setting = "preserved",
      }))
      package.loaded["vimoire.core.preferences"] = nil
      preferences = require("vimoire.core.preferences")

      preferences.set("colorscheme", "vimoire-vellum")

      local content = helpers.read_file(prefs_dir .. "/preferences.json")
      local data = vim.json.decode(content)
      assert.equals("vimoire-vellum", data.colorscheme)
      assert.equals("preserved", data.other_setting)
    end)

    it("updates cached value for subsequent get calls", function()
      preferences.set("colorscheme", "vimoire-parchment")

      assert.equals("vimoire-parchment", preferences.get("colorscheme"))
    end)
  end)
end)
