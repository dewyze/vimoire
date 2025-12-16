local assert = require("luassert")

describe("format.docx", function()
  local Docx = require("vimoire.export.format.docx")

  describe("new", function()
    it("creates config with format docx", function()
      local cfg = Docx.new({ entries = {} })

      assert.equals("docx", cfg.format)
    end)
  end)

  describe("assemble", function()
    it("adds page breaks between entries", function()
      local cfg = Docx.new({ entries = {} })
      local files = {
        { id = "ch1", content = "Chapter one." },
        { id = "ch2", content = "Chapter two." },
        { id = "ch3", content = "Chapter three." },
      }

      local result = cfg:assemble(files)

      assert.truthy(result[1].content:match("\\newpage%s*$"))
      assert.truthy(result[2].content:match("\\newpage%s*$"))
      assert.falsy(result[3].content:match("\\newpage"))
    end)

    it("preserves entry ids", function()
      local cfg = Docx.new({ entries = {} })
      local files = {
        { id = "ch1", content = "Content." },
        { id = "ch2", content = "More." },
      }

      local result = cfg:assemble(files)

      assert.equals("ch1", result[1].id)
      assert.equals("ch2", result[2].id)
    end)
  end)

  describe("pandoc_args", function()
    it("includes lua filter for page breaks", function()
      local cfg = Docx.new({ entries = {} })

      local args = cfg:pandoc_args({})

      local has_filter = false
      for _, arg in ipairs(args) do
        if arg:match("^--lua%-filter=.*pagebreak%.lua$") then
          has_filter = true
          break
        end
      end
      assert.is_true(has_filter)
    end)

    it("includes reference doc when provided", function()
      local cfg = Docx.new({ entries = {} })

      local args = cfg:pandoc_args({ reference_doc = "/path/to/reference.docx" })

      assert.truthy(vim.tbl_contains(args, "--reference-doc=/path/to/reference.docx"))
    end)

    it("omits reference doc when not provided", function()
      local cfg = Docx.new({ entries = {} })

      local args = cfg:pandoc_args({})

      for _, arg in ipairs(args) do
        assert.falsy(arg:match("^--reference%-doc="))
      end
    end)
  end)
end)
