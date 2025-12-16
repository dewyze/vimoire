local assert = require("luassert")
local helpers = require("tests.helpers")

describe("export.config", function()
  local config = require("vimoire.export.config")
  local state = require("vimoire.state")
  local temp_dir

  before_each(function()
    temp_dir = helpers.temp_copy("tests/fixtures/standard")
    state:load(temp_dir)
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  describe("generate", function()
    it("returns YAML string with format and entries", function()
      local yaml = config.generate(state)

      assert.truthy(yaml:match("^format: epub"))
      assert.truthy(yaml:match("entries:"))
    end)

    it("lists all entries in manuscript order", function()
      local yaml = config.generate(state)

      -- Check entries appear in order (fixture has 9 entries)
      local part1tp_pos = yaml:find("part1tp")
      local chap1a_pos = yaml:find("chap1a")
      local intrlud_pos = yaml:find("intrlud")
      local chap2a_pos = yaml:find("chap2a")
      local appndxa_pos = yaml:find("appndxa")

      assert.truthy(part1tp_pos)
      assert.truthy(chap1a_pos)
      assert.is_true(part1tp_pos < chap1a_pos)
      assert.is_true(chap1a_pos < intrlud_pos)
      assert.is_true(intrlud_pos < chap2a_pos)
      assert.is_true(chap2a_pos < appndxa_pos)
    end)

    it("adds comments with entry names and chapter numbers", function()
      local yaml = config.generate(state)

      -- Chapters show name and chapter number
      assert.truthy(yaml:match("chap1a%s+# The Day I Became Sentient %(chapter 1%)"))
      assert.truthy(yaml:match("chap1b%s+# Bread: A Love Story %(chapter 2%)"))
      -- Pages show name and (page)
      assert.truthy(yaml:match("part1tp%s+# Part One %(page%)"))
      assert.truthy(yaml:match("intrlud%s+# Interlude: A Brief History of Crumbs %(page%)"))
    end)
  end)

  describe("parse", function()
    it("extracts format from YAML", function()
      local yaml = [[
format: docx

entries:
  - chap1a
]]
      local parsed = config.parse(yaml)

      assert.equals("docx", parsed.format)
    end)

    it("defaults format to epub when missing", function()
      local yaml = [[
entries:
  - chap1a
]]
      local parsed = config.parse(yaml)

      assert.equals("epub", parsed.format)
    end)

    it("extracts entry IDs from entries list", function()
      local yaml = [[
format: epub

entries:
  - part1tp    # Part One (page)
  - chap1a     # The Beginning (chapter 1)
  - chap1b     # Rising Action (chapter 2)
]]
      local parsed = config.parse(yaml)

      assert.equals(3, #parsed.entries)
      assert.equals("part1tp", parsed.entries[1])
      assert.equals("chap1a", parsed.entries[2])
      assert.equals("chap1b", parsed.entries[3])
    end)

    it("ignores commented-out entries", function()
      local yaml = [[
format: epub

entries:
  - part1tp
  # - chap1a
  - chap1b
]]
      local parsed = config.parse(yaml)

      assert.equals(2, #parsed.entries)
      assert.equals("part1tp", parsed.entries[1])
      assert.equals("chap1b", parsed.entries[2])
    end)

    it("extracts output filename when present", function()
      local yaml = [[
format: epub
output: MyNovel.epub

entries:
  - chap1a
]]
      local parsed = config.parse(yaml)

      assert.equals("MyNovel.epub", parsed.output)
    end)
  end)

  describe("update", function()
    it("preserves format and output from existing config", function()
      local existing = [[
format: docx
output: MyBook.docx

entries:
  - chap1a
]]
      local updated = config.update(state, existing)

      assert.truthy(updated:match("^format: docx"))
      assert.truthy(updated:match("output: MyBook.docx"))
    end)

    it("preserves commented-out entries", function()
      local existing = [[
format: epub

entries:
  - chap1a
  # - chap1b
  - chap1c
]]
      local updated = config.update(state, existing)

      -- chap1b should still be commented
      assert.truthy(updated:match("#%s*-%s*chap1b"))
      -- chap1a and chap1c should not be commented
      assert.truthy(updated:match("%s+- chap1a"))
      assert.truthy(updated:match("%s+- chap1c"))
    end)

    it("adds new entries from manuscript", function()
      local existing = [[
format: epub

entries:
  - chap1a
]]
      local updated = config.update(state, existing)

      -- Should have all 9 entries from fixture
      assert.truthy(updated:match("- part1tp"))
      assert.truthy(updated:match("- chap1b"))
      assert.truthy(updated:match("- intrlud"))
    end)

    it("removes entries no longer in manuscript", function()
      local existing = [[
format: epub

entries:
  - chap1a
  - deleted_entry
  - chap1b
]]
      local updated = config.update(state, existing)

      assert.falsy(updated:match("deleted_entry"))
    end)

    it("keeps entries in manuscript order", function()
      local updated = config.update(state, "format: epub\n\nentries:\n  - chap1a\n")

      local part1tp_pos = updated:find("part1tp")
      local chap1a_pos = updated:find("chap1a")
      local intrlud_pos = updated:find("intrlud")

      assert.is_true(part1tp_pos < chap1a_pos)
      assert.is_true(chap1a_pos < intrlud_pos)
    end)
  end)

  describe("assemble", function()
    it("adds page breaks between entries for docx", function()
      local cfg = config.parse("format: docx\n\nentries:\n  - ch1\n")
      local files = {
        { id = "ch1", content = "Chapter one content." },
        { id = "ch2", content = "Chapter two content." },
        { id = "ch3", content = "Chapter three content." },
      }

      local result = cfg:assemble(files)

      assert.equals(3, #result)
      assert.truthy(result[1].content:match("\\newpage%s*$"))
      assert.truthy(result[2].content:match("\\newpage%s*$"))
      assert.falsy(result[3].content:match("\\newpage"))
    end)

    it("preserves entry ids", function()
      local cfg = config.parse("format: docx\n\nentries:\n  - ch1\n")
      local files = {
        { id = "ch1", content = "Content." },
        { id = "ch2", content = "More." },
      }

      local result = cfg:assemble(files)

      assert.equals("ch1", result[1].id)
      assert.equals("ch2", result[2].id)
    end)

    it("passes through unchanged for epub", function()
      local cfg = config.parse("format: epub\n\nentries:\n  - ch1\n")
      local files = {
        { id = "ch1", content = "Chapter one." },
        { id = "ch2", content = "Chapter two." },
      }

      local result = cfg:assemble(files)

      assert.equals("Chapter one.", result[1].content)
      assert.equals("Chapter two.", result[2].content)
    end)
  end)
end)
