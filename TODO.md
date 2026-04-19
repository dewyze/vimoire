# Todo

Parked work. Written so each item can be picked up cold without conversation context.

## UX bugs

- **Project directory picker drills in before confirming.** When picking a project dir in the browser, selecting a dir enters it and then asks "use this directory?". Expected: selecting a dir from its parent uses it directly. Check the open-project flow (likely `ui/dashboard.lua` or wherever the file picker is wired up for "Open project").

- **`ExportFile:action()` opens binaries in vim.** Pressing Enter on an `.epub`, `.docx`, or `.pdf` in the navigator opens the raw binary in vim instead of handing to the system opener. Fix: dispatch on file extension — use `vim.ui.open` (or `:!open` on macOS) for non-text extensions. Templates/configs (markdown, Lua, CSS) should still open in vim. See `app/lua/vimoire/core/export_file.lua:action()` and `app/lua/vimoire/util/open.lua`.

## Refactors from architecture review

### Move UX into feature modules — `marks`, `images`, finder/navigation

High leverage. `app/lua/config/commands/init.lua` is 372 lines because it owns UX that should live in feature modules. Specifically:

- `vimoire.marks` only exposes `parse(content)`. The picker UI (`commands/init.lua:62-106`) should move to `marks.browse(bufnr)` and `marks.insert()`.
- `vimoire.images` has full file ops; the 110-line `InsertImage` UX in `commands/init.lua` should move to `images.insert()`.
- `vimoire.finder` builds picker data; `config/commands/navigation.lua` (~200 lines of near-duplicate picker bodies) runs them. Collapse both into `vimoire.navigation.picker` with `picker.manuscript()`, `picker.planning()`, etc.

After this, `commands/init.lua` is ~200 lines of thin dispatchers.

### Fix two-paths-to-colorscheme in `vimoire.config`

`vimoire.config.load()` memoizes via `dofile`, but `effective_colorscheme()` does `dofile` again outside the memoized path. Future-you will add a third precedence source and get bit. Fix: memoize once, read cache in both places. Small, ~5 min.

### Extract `THEMES` array out of `config/commands/init.lua`

Hardcoded theme list with descriptions and order lives in commands/init.lua around line 133. It's content, not command logic. Move to `app/lua/vimoire/themes.lua` as a data module.

### Declarative synthetic-folder table in `state.lua`

The 7 inline `Folder.new(...)` calls for manuscript/planning/characters/etc. at `state.lua:67-85` are effectively config masquerading as code. A declarative table iterated to construct would halve the lines. **Only worth doing after refactor 2d** (unified item construction) — before that, the folders and scanners are still entangled.

## Cross-cutting cleanup

### Concerted nested-if audit

Multiple hot spots across the codebase have 3-4 levels of `if`/`while`/`for` nesting. Rather than tackle piecemeal, do one concerted pass:

- `ExportFile.scan_folder` and `Board.scan_folder` (just moved; still ugly — use `plenary.scandir.scan_dir(path, { depth = 1 })` to flatten)
- Any others the audit turns up

Dispatch an agent (cartographer-style) to catalog nested-conditional hot spots and propose flattened shapes. Then tackle in one branch.

## Code smells to verify

- **`DocumentBase:destroy` silently turns chapter notes into a planning item** (`document_base.lua`, around lines 107-126, last checked on main). Useful UX for preserving notes on delete, or surprising side effect? Test the flow: delete a chapter with notes, check if it appears in planning's orphaned_notes.

- **Measure `state:rebuild()` perf on a real book.** It runs on every rename/move/delete/add/toggle_kind. Estimated sub-10ms on typical books, but unverified. Wrap with `vim.uv.hrtime()` and log the delta during active writing. Only relevant if it feels sluggish.

## In-progress branches

- `simplify_state_rebuild` — 2 commits on top of main (`state:register` method, scanner extraction). Refactor 2d (unify manuscript + planning item construction) is still to do. Plenary.scandir cleanup absorbed into "concerted nested-if audit" above.
