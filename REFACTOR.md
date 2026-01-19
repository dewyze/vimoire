# Plan: Migrate Telescope Pickers to Snacks

Replace telescope.nvim dependency with snacks.nvim pickers (already a dependency).

## Current State

- 6 telescope pickers in `app/lua/telescope/_extensions/vimoire.lua`
- Keymaps dynamically generated in `app/lua/config/keymaps.lua` (lines 5-9)
- Snacks already used for 3 pickers: VimoireSnippets, VimoireMarks, VimoireInsertImage

## Approach

Migrate one picker at a time. Each step is independently committable/testable.

---

## Phase 1: Create Finder Module

Create `app/lua/vimoire/finder.lua` with shared entry builders extracted from telescope extension:

- `build_manuscript_entries()` - flattens manuscript items
- `build_planning_entries(planning_key)` - builds from characters/settings/reference
- `build_all_entries()` - combines manuscript + all planning sections
- `build_exports_entries()` - scans exports directory

These are pure functions, no telescope dependency.

---

## Phase 2: Migrate Pickers (one at a time)

### 2.1: Manuscript Picker

1. Add `VimoireManuscript` command to `commands.lua` using `Snacks.picker()`
2. Update keymap for `<leader>fm` to call `:VimoireManuscript`
3. Test: `<leader>fm` opens picker, selection opens file
4. Commit

### 2.2: Characters Picker

1. Add `VimoireCharacters` command
2. Update keymap for `<leader>fc`
3. Test
4. Commit

### 2.3: Settings Picker

1. Add `VimoireSettings` command
2. Update keymap for `<leader>fp`
3. Test
4. Commit

### 2.4: Reference Picker

1. Add `VimoireReference` command
2. Update keymap for `<leader>fr`
3. Test
4. Commit

### 2.5: Navigate Picker

1. Add `VimoireNavigate` command (combines all entries)
2. Update keymap for `<leader>ff`
3. Test
4. Commit

### 2.6: Exports Picker

1. Add `VimoireExports` command (different pattern - scans directory)
2. Update keymap for `<leader>fe`
3. Test
4. Commit

---

## Phase 3: Cleanup

1. Remove `app/lua/telescope/_extensions/vimoire.lua`
2. Remove `app/lua/plugins/telescope.lua`
3. Update keymaps.lua - remove dynamic telescope command generation (lines 5-9)
4. Test all 6 pickers still work
5. Commit

---

## Snacks Picker Pattern

Based on existing VimoireMarks implementation:

```lua
vim.api.nvim_create_user_command("VimoireManuscript", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local config = require("vimoire.config")

  local entries = finder.build_manuscript_entries()
  local preview_enabled = config.get("finder.preview")

  Snacks.picker({
    title = "Manuscript",
    items = vim.tbl_map(function(entry)
      return {
        text = (entry.display_number ~= "" and entry.display_number .. "  " or "") .. entry.name,
        entry = entry,
        file = entry.path,  -- for preview
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse manuscript" })
```

---

## Notes

- `preview = "file"` uses snacks built-in file preview (respects `file` field on items)
- Entry builders return same structure, just consumed differently
- Keymaps change from `:Telescope vimoire X` to `:VimoireX`
