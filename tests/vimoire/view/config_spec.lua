local assert = require("luassert")

describe("view.config", function()
  local config = require("vimoire.view.config")

  local ALL_KINDS = {
    "manuscript", "planning", "characters", "settings", "reference",
    "section", "chapter", "page", "subfolder", "planning_item"
  }

  describe("completeness", function()
    for _, kind in ipairs(ALL_KINDS) do
      it("has config for " .. kind, function()
        assert.is_not_nil(config[kind])
      end)
    end
  end)

  describe("required fields", function()
    for _, kind in ipairs(ALL_KINDS) do
      it(kind .. " has icon", function()
        assert.is_not_nil(config[kind].icon)
      end)

      it(kind .. " has highlight", function()
        assert.is_not_nil(config[kind].highlight)
      end)
    end
  end)

  describe("immutable folders", function()
    local IMMUTABLE = { "manuscript", "planning", "characters", "settings", "reference" }
    for _, kind in ipairs(IMMUTABLE) do
      it(kind .. " is marked immutable", function()
        assert.is_true(config[kind].immutable)
      end)
    end
  end)

  describe("mutable items", function()
    local MUTABLE = { "section", "chapter", "page", "subfolder", "planning_item" }
    for _, kind in ipairs(MUTABLE) do
      it(kind .. " is not marked immutable", function()
        assert.is_nil(config[kind].immutable)
      end)
    end
  end)
end)
