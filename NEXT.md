# Multi-Source Refactor

## Completed
- [x] Add `action()` interface to all item types
- [x] Extract `util/open.lua` for shared file opening logic
- [x] Update `commands.lua` to use `action()` interface

## Next Steps

### 1. Extract Shared Base
Move shared node-building and commands to `neotree_base.lua`:
- `node_from_item(item)` — builds neo-tree node from item
- `build_items_nodes(items)` — recursive node builder
- `build_planning_items(items)` — planning-specific recursion
- Shared commands: `refresh`, `open`, `toggle_node`, `close_node`, etc.

### 2. Reorganize File Structure
```
navigation/
  open.lua                    # unchanged
  neotree_base.lua            # new: shared bits
  sources/
    manuscript/
      init.lua                # current source, minus export
      commands.lua            # add, rename, delete, move, notes
    export/
      init.lua                # new source
      commands.lua            # export-specific commands
  neotree_source/             # delete after migration
```

### 3. Create Export Source
- Build tree with action nodes: "Generate Config", "Run Export..."
- Templates, Configs, Output folders with files
- Register as neo-tree source `export`

### 4. Add Action Node Support
Action nodes have an `action` function instead of `text_path()`. The shared `open` command already handles this via `item:action()`.

For export source, create action items in state or build them directly in the source's navigate function.

### 5. Remove Export from Manuscript Source
Once export source is working, remove the Export folder from manuscript's tree.

### 6. Add Switching Commands/Keymaps
- `gvm` → `:Neotree source=manuscript`
- `gve` → `:Neotree source=export`
- Commands: `:VimoireTree`, `:VimoireExportView`

### 7. Update Neotree Registration
Ensure both sources are registered in the neo-tree setup.

## Design Decisions

**Action nodes:** Built directly in export source's `navigate()`, not in state. They're UI-only, no persistence needed.

**Shared components:** `components.lua` stays shared — icon/name rendering works for both sources.

**No source selector tab bar:** Use keymaps instead. Simpler, and we dynamically set display_name for book title.
