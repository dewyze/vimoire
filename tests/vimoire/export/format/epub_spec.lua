local assert = require("luassert")

describe("format.epub", function()
  local Epub = require("vimoire.export.format.epub")

  describe("new", function()
    it("creates config with format epub", function()
      local cfg = Epub.new({ entries = {} })

      assert.equals("epub", cfg.format)
    end)
  end)

  describe("assemble", function()
    it("passes files through unchanged", function()
      local cfg = Epub.new({ entries = {} })
      local files = {
        { id = "ch1", content = "Chapter one." },
        { id = "ch2", content = "Chapter two." },
      }

      local result = cfg:assemble(files)

      assert.equals("Chapter one.", result[1].content)
      assert.equals("Chapter two.", result[2].content)
    end)
  end)

  describe("pandoc_args", function()
    it("includes split-level for chapter separation", function()
      local cfg = Epub.new({ entries = {} })

      local args = cfg:pandoc_args({})

      assert.truthy(vim.tbl_contains(args, "--split-level=1"))
    end)

    it("includes css when provided", function()
      local cfg = Epub.new({ entries = {} })

      local args = cfg:pandoc_args({ css_path = "/path/to/epub.css" })

      assert.truthy(vim.tbl_contains(args, "--css=/path/to/epub.css"))
    end)

    it("omits css when not provided", function()
      local cfg = Epub.new({ entries = {} })

      local args = cfg:pandoc_args({})

      for _, arg in ipairs(args) do
        assert.falsy(arg:match("^--css="))
      end
    end)
  end)
end)
