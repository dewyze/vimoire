# Focus Mode — Auto-Enable Plan

## Overview

Focus mode (margins) now works manually via `:VimoireFocus`. This plan covers auto-enabling when opening prose files.

## Goals

1. Auto-enable focus mode when opening prose files from neo-tree
2. Auto-enable focus mode when opening prose files from Snacks finder
3. Optionally close neo-tree when opening a file

## Config Options

```lua
editor = {
  focus_mode = true,           -- auto-enable on prose files
  close_neotree_on_open = true -- close neo-tree when opening a file
}
```

## Implementation Options

### Option A: Neo-tree Events

Subscribe to neo-tree's FILE_OPENED event:

```lua
events.FILE_OPENED →
  if is_prose_file(path) and config.focus_mode then
    if config.close_neotree_on_open then
      close_neotree()
    end
    margins.enable()
  end
```

**Risk:** Timing issues with event firing before/after window state settles.

### Option B: Wrap Open Command

Our files are opened via `vimoire.navigation.open`. We could add focus mode logic there:

```lua
-- in navigation.open
function M.open_item(item)
  -- existing open logic
  vim.cmd("edit " .. item:text_path())
  vim.b.vimoire_item_id = item.id

  -- new focus logic
  if is_prose_file(item) and config.focus_mode then
    if config.close_neotree_on_open then
      close_neotree()
    end
    margins.enable()
  end
end
```

**Advantage:** Single integration point for both neo-tree and Snacks finder.

### Option C: FileType Autocmd

Already stubbed in focus.lua (commented out):

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimoire_prose",
  callback = function()
    if not margins.is_active() then
      margins.enable()
    end
  end,
})
```

**Advantage:** Works regardless of how file was opened.
**Risk:** May fire at unexpected times, timing with window layout.

## Recommendation

Try Option B first—wrap the open command. It's the most controlled approach and handles both neo-tree and Snacks in one place.

## File Changes

- `app/lua/vimoire/navigation.lua` — add focus mode logic to open_item
- `app/lua/vimoire/config.lua` — add close_neotree_on_open option
- `app/lua/vimoire/focus.lua` — remove commented FileType autocmd
