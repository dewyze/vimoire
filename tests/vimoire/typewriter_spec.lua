local helpers = require("tests.helpers")

describe("typewriter", function()
  local typewriter
  local preferences
  local config

  before_each(function()
    helpers.reset()

    -- Clear package cache
    package.loaded["vimoire.typewriter"] = nil
    package.loaded["vimoire.core.preferences"] = nil
    package.loaded["vimoire.config"] = nil

    -- Setup preferences with temp directory
    preferences = require("vimoire.core.preferences")
    preferences.set_directory(helpers.temp_dir())

    config = require("vimoire.config")
    typewriter = require("vimoire.typewriter")
  end)

  after_each(function()
    preferences.reset_directory()
  end)

  describe("is_enabled", function()
    it("returns false by default", function()
      assert.is_false(typewriter.is_enabled())
    end)

    it("returns preference value when set to true", function()
      preferences.set("typewriter_scrolling", true)
      assert.is_true(typewriter.is_enabled())
    end)

    it("returns preference value when set to false", function()
      preferences.set("typewriter_scrolling", false)
      assert.is_false(typewriter.is_enabled())
    end)
  end)
end)
