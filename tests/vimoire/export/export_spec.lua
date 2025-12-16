local assert = require("luassert")
local helpers = require("tests.helpers")

describe("export", function()
  local export = require("vimoire.export")
  local state = require("vimoire.state")
  local Path = require("plenary.path")
  local temp_dir

  before_each(function()
    temp_dir = helpers.temp_copy("tests/fixtures/standard")
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  describe("prepare_files", function()
    it("returns processed entries in manuscript order", function()
      local files = export.prepare_files(state)

      assert.equals(9, #files)
      -- First entry: part1tp (page)
      assert.equals("part1tp", files[1].id)
      assert.truthy(files[1].content:match("Part One"))
      -- Second entry: chap1a (chapter 1)
      assert.equals("chap1a", files[2].id)
    end)

    it("applies chapter numbering to chapters only", function()
      -- Add {{chapter.num}} to a chapter file
      helpers.write_file(
        temp_dir .. "/entries/chap1a/prose.md",
        "# Chapter {{chapter.num}}\nTest content."
      )

      local files = export.prepare_files(state)

      local chap1a = files[2] -- second entry after part1tp
      assert.truthy(chap1a.content:match("# Chapter 1"))
    end)

    it("strips marks and todos", function()
      helpers.write_file(
        temp_dir .. "/entries/chap1a/prose.md",
        "He walked {{mark}}slowly.{{todo:fix}}"
      )

      local files = export.prepare_files(state)

      local chap1a = files[2]
      -- Title injected for chapters, then body content
      assert.truthy(chap1a.content:match("He walked slowly%.$"))
      assert.falsy(chap1a.content:match("{{mark}}"))
      assert.falsy(chap1a.content:match("{{todo"))
    end)
  end)

  describe("write_temp_files", function()
    it("writes processed content to temp directory", function()
      local files = {
        { id = "test1", content = "Content one" },
        { id = "test2", content = "Content two" },
      }

      local temp_path, file_list = export.write_temp_files(files)

      assert.equals(2, #file_list)
      assert.truthy(Path:new(file_list[1]):exists())
      assert.equals("Content one", helpers.read_file(file_list[1]))

      helpers.cleanup(temp_path)
    end)
  end)

  describe("build_pandoc_args", function()
    local config = require("vimoire.export.config")

    it("builds epub args with metadata", function()
      local cfg = config.for_format("epub")
      local args = export.build_pandoc_args({
        input_files = { "/tmp/001.md", "/tmp/002.md" },
        output_path = "/output/book.epub",
        title = "My Book",
        author = "Jane Doe",
        language = "en",
        css_path = "/templates/epub.css",
      }, cfg)

      assert.truthy(vim.tbl_contains(args, "/tmp/001.md"))
      assert.truthy(vim.tbl_contains(args, "/tmp/002.md"))
      assert.truthy(vim.tbl_contains(args, "-o"))
      assert.truthy(vim.tbl_contains(args, "/output/book.epub"))
      assert.truthy(vim.tbl_contains(args, "--metadata"))
      assert.truthy(vim.tbl_contains(args, "title=My Book"))
    end)

    it("builds docx args with reference doc", function()
      local cfg = config.for_format("docx")
      local args = export.build_pandoc_args({
        input_files = { "/tmp/001.md" },
        output_path = "/output/book.docx",
        title = "My Book",
        author = "Jane Doe",
        language = "en",
        reference_doc = "/templates/reference.docx",
      }, cfg)

      assert.truthy(vim.tbl_contains(args, "--reference-doc=/templates/reference.docx"))
      assert.falsy(vim.tbl_contains(args, "--split-level=1"))
    end)
  end)

  describe("run", function()
    it("creates epub in exports/output", function()
      -- Skip if pandoc not available
      if vim.fn.executable("pandoc") ~= 1 then
        return
      end

      local result = export.run(state, { format = "epub" })

      assert.is_true(result.success)
      assert.truthy(result.output_path:match("%.epub$"))
      assert.truthy(Path:new(result.output_path):exists())
    end)
  end)

  describe("run_with_config", function()
    it("exports only entries listed in config", function()
      -- Skip if pandoc not available
      if vim.fn.executable("pandoc") ~= 1 then
        return
      end

      -- Create a config with only 2 entries
      local config_content = [[
format: epub

entries:
  - chap1a
  - chap1b
]]
      local config_path = temp_dir .. "/exports/configs/test.yml"
      vim.fn.mkdir(temp_dir .. "/exports/configs", "p")
      helpers.write_file(config_path, config_content)

      local result = export.run_with_config(state, config_path)

      assert.is_true(result.success)
      assert.truthy(result.output_path:match("%.epub$"))
    end)

    it("uses format from config", function()
      if vim.fn.executable("pandoc") ~= 1 then
        return
      end

      local config_content = [[
format: docx

entries:
  - chap1a
]]
      local config_path = temp_dir .. "/exports/configs/test.yml"
      vim.fn.mkdir(temp_dir .. "/exports/configs", "p")
      helpers.write_file(config_path, config_content)

      local result = export.run_with_config(state, config_path)

      assert.is_true(result.success)
      assert.truthy(result.output_path:match("%.docx$"))
    end)

    it("returns error when config file not found", function()
      local result = export.run_with_config(state, temp_dir .. "/nonexistent.yml")

      assert.is_false(result.success)
      assert.truthy(result.error:match("Could not open"))
    end)

    it("returns error when entries list is empty", function()
      local config_content = [[
format: epub

entries:
]]
      local config_path = temp_dir .. "/exports/configs/empty.yml"
      vim.fn.mkdir(temp_dir .. "/exports/configs", "p")
      helpers.write_file(config_path, config_content)

      local result = export.run_with_config(state, config_path)

      assert.is_false(result.success)
      assert.truthy(result.error:match("No entries in config"))
    end)
  end)
end)
