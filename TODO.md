# Todo

Parked work. Written so each item can be picked up cold without conversation context.

## Kinds-table refactor — active, branch `kinds_refactor`

Replace the 5 per-kind classes (`Chapter`, `Page`, `PlanningItem`, `ManuscriptSection`, `PlanningSection`) with a data-driven `core/kinds.lua` config table + a single `core/item.lua` class that reads from it. Drops `DocumentBase`/`SectionBase`/per-kind-class shims along the way.

**Full plan + rationale:** `docs/COMPOSITION.md`. Includes the kinds.lua shape, the 6-step migration sequence, per-step risk gates, and why we picked this shape over the originally-pitched component hybrid.

**Risk posture:** real but bounded. Step 3 (`Entry.build` switchover) is the integration moment — full state_spec pass + manual smoke test required. Halt-mid-refactor is the worst state, so each commit on the branch must be green and ship-able. Steps 1-2 are zero-risk (pure additions), step 3 is high-risk (semantic switch), steps 4-5 are low-risk (cleanup with tests as safety net).

### Items folded into this refactor

Don't tackle separately. These are covered by or directly adjacent to the kinds-table work:

- **`DocumentBase:destroy` silently creates a planning item from notes.** The "preserve notes on delete" behavior is tied to the current class hierarchy. Rethink during the migration — likely a `preserve_on_delete = true` flag in the kinds entry, or stays as logic on Item with no kind-flag (acts on presence of notes file).
- **Declarative synthetic-folder table in `state.lua`.** Synthetic folders (manuscript, planning, characters, etc.) constructed at rebuild time. Open question in COMPOSITION.md whether they fold into Item or stay as Folder. Decide during the migration.

## Skip picker when add_options has only one entry

When a folder exposes exactly one `add_options` entry (planning subfolders only offer "Item"), the add-item flow still prompts a `vim.ui.select` picker with a single choice. Should bypass the picker and execute directly.

**Where:** prompt lives in the neo-tree add-item handler (likely under `app/lua/vimoire/navigation/sources/manuscript/`). Check `#options == 1` before invoking `vim.ui.select`; call `options[1].execute(...)` directly if so.

## Neo-tree marker for notes and comments

Visual signal in the tree when a chapter or page has authored `notes.md` or non-empty `comments.json`. Currently both are invisible in neo-tree.

**Data side:**
- `Item:has_notes()` → `Path:new(self:notes_path()):exists()`. File is lazy, so existence is a valid signal.
- `Item:has_comments()` → requires reading `comments.json` and checking `#data.comments > 0`. File existence is NOT valid while empty comments.json keeps getting written (see next TODO — landing that first makes this a simple existence check).

**Render side:** neo-tree manuscript source adds a suffix or icon to affected nodes.

## Stop persisting empty comments.json

`comments/init.lua:76` calls `store:save(comments)` on every prose `BufWritePost`, and `comments/store.lua:32-40` writes unconditionally. Result: `{"version":1,"comments":[]}` lands next to every prose file the user ever saves, regardless of comment usage. Shows up as a lot of empty-looking tracked files in the user's project.

**Fix:** in `save_buffer` (comments/init.lua:58), when `#comments == 0`: delete `comments.json` if it exists, otherwise no-op. Only write when there's something to persist.

**Bonus:** makes `has_comments()` (see previous TODO) a valid existence check instead of needing a JSON read.

## Expose notes.md (and comments) for management

Users who write notes on a chapter can't later delete them from within vimoire — `notes.md` is a real file but never appears as a navigable node. Same for `comments.json`. Need an in-app way to remove them.

**Options:**
- Expand chapter/page nodes in neo-tree to show `notes.md` / `comments.json` as children when they exist. Delete keymap works on them.
- Context-menu or keybind on the chapter/page node: "Delete notes", "Clear comments".

Expandable-child approach is more discoverable; context-menu keeps the tree cleaner. Pick one.

