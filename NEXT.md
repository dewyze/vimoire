# Multi-Source Refactor

## Completed
- [x] Add `action()` interface to all item types
- [x] Extract `util/open.lua` for shared file opening logic
- [x] Update `commands.lua` to use `action()` interface
- [x] Reorganize into self-contained sources (`sources/manuscript/`, `sources/export/`)
- [x] Remove export from manuscript source
- [x] Add switching keymaps (`gvm`, `gve`)
- [x] Update neotree registration for both sources
- [x] Delete old `neotree_source/` directory

## Current Structure
```
navigation/
  open.lua                    # used by telescope
  sources/
    manuscript/
      init.lua                # self-contained source
      commands.lua            # setmetatable fallback to cc
      components.lua          # rendering
    export/
      init.lua                # self-contained source
      commands.lua            # setmetatable fallback to cc
      components.lua          # rendering
```

## Future Enhancements

### Action Nodes in Export Source
Add action nodes like "Generate Config", "Run Export..." to the export tree.
Action nodes have an `action` function instead of `text_path()`. The `open` command already handles this via `item:action()`.

Build action items directly in the export source's `navigate()` function — they're UI-only, no persistence needed.

### Commands
- `:VimoireTree` — open manuscript source
- `:VimoireExportView` — open export source

## Design Decisions

**Self-contained sources:** Each source has its own node building and commands. Small duplication (~30 lines) preferred over abstraction layers.

**Explicit cc assignments:** Neo-tree validates mappings at setup time, so commands must be explicitly assigned (not via metatable).

**Source selector tabs:** Winbar shows "Manuscript" and "Export" tabs. Book title appears in window titlestring instead.
