local assert = require("luassert")
local helpers = require("tests.helpers")

describe("config", function()
  local config
  local prefs_dir
  local user_config_dir
  local original_expand

  before_each(function()
    package.loaded["vimoire.config"] = nil
    package.loaded["vimoire.preferences"] = nil

    prefs_dir = helpers.temp_dir()
    user_config_dir = helpers.temp_dir()

    original_expand = vim.fn.expand
    vim.fn.expand = function(path)
      if path == "~/.vimoire" then
        return prefs_dir
      end
      if path == "~/.vimoire/config.lua" then
        return user_config_dir .. "/config.lua"
      end
      return original_expand(path)
    end

    config = require("vimoire.config")
  end)

  after_each(function()
    vim.fn.expand = original_expand
    helpers.cleanup(prefs_dir)
    helpers.cleanup(user_config_dir)
  end)

  describe("effective_colorscheme", function()
    it("returns default when no user config or preferences exist", function()
      assert.equals("inkwell", config.effective_colorscheme())
    end)

    it("returns preferences colorscheme when no user config exists", function()
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "parchment",
      }))
      package.loaded["vimoire.preferences"] = nil

      assert.equals("parchment", config.effective_colorscheme())
    end)

    it("returns user config colorscheme over preferences", function()
      helpers.write_file(user_config_dir .. "/config.lua", [[
        return { colorscheme = "umbra" }
      ]])
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "parchment",
      }))
      package.loaded["vimoire.preferences"] = nil

      assert.equals("umbra", config.effective_colorscheme())
    end)

    it("returns preferences colorscheme when user config exists but has no colorscheme", function()
      helpers.write_file(user_config_dir .. "/config.lua", [[
        return { editor = { textwidth = 100 } }
      ]])
      helpers.write_file(prefs_dir .. "/preferences.json", vim.json.encode({
        colorscheme = "vellum",
      }))
      package.loaded["vimoire.preferences"] = nil

      assert.equals("vellum", config.effective_colorscheme())
    end)
  end)
end)
