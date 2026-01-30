local assert = require("luassert")

describe("export.format.pdf", function()
  local Pdf = require("vimoire.export.format.pdf")

  describe("new", function()
    it("creates format with pdf type", function()
      local pdf = Pdf.new({ entries = {} })
      assert.equals("pdf", pdf.format)
    end)

    it("stores output filename", function()
      local pdf = Pdf.new({ output = "book.pdf", entries = {} })
      assert.equals("book.pdf", pdf.output)
    end)

    it("stores entries", function()
      local pdf = Pdf.new({ entries = { "a", "b" } })
      assert.same({ "a", "b" }, pdf.entries)
    end)
  end)

  describe("assemble", function()
    it("adds page breaks between entries", function()
      local pdf = Pdf.new({ entries = {} })
      local files = {
        { id = "a", content = "Chapter 1" },
        { id = "b", content = "Chapter 2" },
        { id = "c", content = "Chapter 3" },
      }

      local result = pdf:assemble(files)

      assert.equals(3, #result)
      assert.matches("\\newpage", result[1].content)
      assert.matches("\\newpage", result[2].content)
      assert.is_nil(result[3].content:match("\\newpage"))
    end)

    it("preserves entry ids", function()
      local pdf = Pdf.new({ entries = {} })
      local files = {
        { id = "abc", content = "content" },
      }

      local result = pdf:assemble(files)

      assert.equals("abc", result[1].id)
    end)
  end)

  describe("find_engine", function()
    it("returns a string when engine is available", function()
      local engine = Pdf.find_engine()
      -- May or may not be available in test environment
      if engine then
        assert.is_string(engine)
      end
    end)
  end)

  describe("pandoc_args", function()
    it("includes pdf-engine argument", function()
      local pdf = Pdf.new({ entries = {} })
      local args = pdf:pandoc_args({})

      local has_engine = false
      for _, arg in ipairs(args) do
        if arg:match("^--pdf%-engine=") then
          has_engine = true
          break
        end
      end

      -- Only check if an engine is available
      if Pdf.find_engine() then
        assert.is_true(has_engine)
      end
    end)

    it("includes lua-filter argument", function()
      local pdf = Pdf.new({ entries = {} })
      local args = pdf:pandoc_args({})

      local has_filter = false
      for _, arg in ipairs(args) do
        if arg:match("^--lua%-filter=") then
          has_filter = true
          break
        end
      end

      assert.is_true(has_filter)
    end)
  end)
end)
