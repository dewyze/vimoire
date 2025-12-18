local assert = require("luassert")
local helpers = require("tests.helpers")

describe("Orphan detection", function()
  local state = require("vimoire.state")
  local temp_dir

  after_each(function()
    helpers.cleanup(temp_dir)
    helpers.reset_state()
  end)

  it("detects orphaned entries not in manifest", function()
    temp_dir = helpers.temp_copy("tests/fixtures/flat")

    -- Create orphan: entry folder exists but not in manifest
    helpers.write_file(temp_dir .. "/entries/orphan1/prose.md", "Some content")

    state:load(temp_dir)

    -- Orphan should be recovered and appear in items
    local recovered = state.items["orphan1"]
    assert.is_not_nil(recovered)
  end)

  it("recovers orphan as page at bottom of manuscript", function()
    temp_dir = helpers.temp_copy("tests/fixtures/flat")
    helpers.write_file(temp_dir .. "/entries/orphan1/prose.md", "Some content")

    state:load(temp_dir)

    local recovered = state.items["orphan1"]
    assert.equals("page", recovered.kind)

    -- Should be at end of manuscript.items
    local last_item = state.manuscript.items[#state.manuscript.items]
    assert.equals("orphan1", last_item.id)
  end)

  it("uses title from frontmatter as name", function()
    temp_dir = helpers.temp_copy("tests/fixtures/flat")
    local content = [[---
title: My Lost Chapter
---

Some prose here.
]]
    helpers.write_file(temp_dir .. "/entries/orphan1/prose.md", content)

    state:load(temp_dir)

    local recovered = state.items["orphan1"]
    assert.equals("My Lost Chapter", recovered.name)
  end)

  it("falls back to 'Recovered: id' when no frontmatter title", function()
    temp_dir = helpers.temp_copy("tests/fixtures/flat")
    helpers.write_file(temp_dir .. "/entries/orphan1/prose.md", "No frontmatter here")

    state:load(temp_dir)

    local recovered = state.items["orphan1"]
    assert.equals("Recovered: orphan1", recovered.name)
  end)

  it("saves manifest after recovery", function()
    temp_dir = helpers.temp_copy("tests/fixtures/flat")
    helpers.write_file(temp_dir .. "/entries/orphan1/prose.md", "Some content")

    state:load(temp_dir)

    -- Reload manifest from disk to verify it was saved
    local content = helpers.read_file(temp_dir .. "/manuscript.json")
    assert.truthy(content:match('"orphan1"'))
  end)

  it("does not modify manifest when no orphans found", function()
    temp_dir = helpers.temp_copy("tests/fixtures/flat")

    -- Get original file content
    local original = helpers.read_file(temp_dir .. "/manuscript.json")

    state:load(temp_dir)

    local after = helpers.read_file(temp_dir .. "/manuscript.json")
    assert.equals(original, after)
  end)
end)
