# Todo

Parked work. Written so each item can be picked up cold without conversation context.


## Items register their own paths (remove nil stubs from non-document classes)

`state:register` currently probes `notes_path()` and `comments_path()` on every item, requiring nil-returning stubs on ContainerItem, Folder, Board, Book, and ExportFile. The fix: items declare what they contribute via `registered_paths()`. DocumentItem returns its prose and notes paths; everything else returns `{}` or just the text path. `state:register` loops over whatever the item provides — no probing, no stubs.

Same pattern applies to `commands.lua:M.notes`: becomes `item:open_notes()` where DocumentItem opens the file and everything else is a no-op. Callers stop interrogating; items declare and respond.

**Where:** `state:register` in `state.lua`, `M.notes` in `navigation/sources/manuscript/commands.lua`, `notes_path`/`comments_path` stubs on ContainerItem (`item.lua`), Folder, Board, Book, ExportFile.

## Declarative synthetic-folder table in state.lua

Synthetic folders (manuscript, planning, characters, etc.) are constructed imperatively in `state.lua` at rebuild time. Carry-over from the kinds-table refactor — the open question was whether they fold into `Item` or stay as `Folder`. Decision deferred: they stayed as `Folder` for v1 since they have a different lifecycle (constructed at rebuild, never persisted to manuscript.json).

**If revisited:** synthetic folders could become `Item` instances with `container = true, synthetic = true` in kinds.lua, or the `Folder` class could be absorbed. The main motivation would be unifying the `state.items` interface further.

## Expose notes.md (and comments) for management

Users who write notes on a chapter can't later delete them from within vimoire — `notes.md` is a real file but never appears as a navigable node. Same for `comments.json`. Need an in-app way to remove them.

**Options:**
- Expand chapter/page nodes in neo-tree to show `notes.md` / `comments.json` as children when they exist. Delete keymap works on them.
- Context-menu or keybind on the chapter/page node: "Delete notes", "Clear comments".

Expandable-child approach is more discoverable; context-menu keeps the tree cleaner. Pick one.

## Fix subfolder movement escape (parent_subfolder tracking)

Planning subfolders can get stuck nested inside another subfolder with no way out. Root cause: `movement.lua:29` escapes via `item.parent_section`, which is a manuscript-only concept. `visit_planning` in `state.lua` doesn't track the containing subfolder, so nested subfolders have no escape path.

**Fix:** mirror what `visit_manuscript` does — pass the containing subfolder through `visit_planning` recursion, set `item.parent_subfolder` on each item. In `movement.lua`, add `elseif item.parent_subfolder then` parallel to the `parent_section` branch.

**Note:** this is pre-existing behavior, not introduced by the kinds-table refactor.

## Plotting board keyboard shortcut discoverability

Plotting board keybindings aren't surfaced anywhere accessible. Users have to dig through source to find them.

**Options:** add a `?` help overlay in the board buffer (similar to neo-tree's `?`), or show available keys in a statusline/virtual text hint when the board is focused.

**Where to look:** plotting keymaps likely live under `app/lua/vimoire/plotting/`.

## Consolidate section and subfolder into one kind

After the kinds-table refactor, `section` and `subfolder` have identical structure — both `container = true`, same movement behavior, same tree mechanics. The only differences are `category` (prose vs. planning) and `add_options` (what children they accept). The naming is legacy from separate class hierarchies.

**Decision:** determine whether to merge into a single `container` kind parameterized by category/add_options, or keep them as named aliases for clarity. Either way, the movement fix above applies to both identically.

