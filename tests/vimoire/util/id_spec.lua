local assert = require("luassert")

describe("id", function()
  local id = require("vimoire.util.id")

  describe("generate", function()
    it("returns a 6-character string", function()
      local result = id.generate()
      assert.equals(6, #result)
    end)

    it("contains only lowercase alphanumeric characters", function()
      local result = id.generate()
      assert.is_true(result:match("^[a-z0-9]+$") ~= nil)
    end)

    it("generates unique values", function()
      local seen = {}
      for _ = 1, 100 do
        local result = id.generate()
        assert.is_nil(seen[result], "Duplicate ID generated: " .. result)
        seen[result] = true
      end
    end)

    it("avoids collisions with provided IDs", function()
      local existing = { "abc123", "xyz789" }
      local result = id.generate(existing)
      assert.not_equals("abc123", result)
      assert.not_equals("xyz789", result)
    end)
  end)
end)
