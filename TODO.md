# Todo

Parked work. Written so each item can be picked up cold without conversation context.

## Composition refactor — biggest, needs its own plan

Large refactor applying "composition over classification" (see `.claude/CLAUDE.md`, OO Design Principles section, and `~/dev/dewzy/docs/engineering/data_architecture_rationale.md` for the canonical rationale).

**The idea:** replace vimoire's `kind`-based class hierarchy with a single `Item` core and optional behavior components. Chapters, pages, planning items, subfolders, export files, boards, etc. stop being distinct classes and become combinations of components (TextContent, NotesContent, Container, Numbering, FilesystemBacked, Immutable, etc.). Data in manuscript.json describes behaviors directly instead of routing through `kind`.

**Working notes + design-doc checklist:** `docs/COMPOSITION.md`. Add observations there as they surface during unrelated work.

**Risk posture:** real but bounded — dev/stable split insulates active writing, recent test coverage guards structural output of `state:rebuild`. Biggest failure mode is stopping halfway (mixed hierarchy + composition); staging must commit to completion.

### Items folded into this refactor

Don't tackle separately. These are covered by or directly adjacent to the composition work:

- **Refactor 2d — unify `state:rebuild` walker.** Composition eliminates the kind dispatch in `Entry.build` entirely; there's no unified walker to build because there's no walker split. The `simplify_state_rebuild` branch's partial progress (2a `state:register`, 2b+2c scanner extraction) is keepable mid-state; 2d is superseded.
- **Declarative synthetic-folder table in `state.lua`.** Synthetic folders may stop being a special case — they'd just be Items with a Container component and no TextContent. Revisit shape during the refactor.
- **`DocumentBase:destroy` silently creates a planning item from notes.** The "preserve notes on delete" behavior is tied to the current class hierarchy. Rethink under composition — is "Preservable" a component? Does it live with NotesContent or independently?
- **Type-dispatch portions of the nested-if audit.** Any nested-`if` that's actually type-dispatch in disguise is eliminated by composition. Structural nested-ifs (scandir loops, etc.) stay in the general audit below.

---

## Unrelated refactors — keep separate

These don't intersect with composition. Do them whenever, independently.

### Move UX into feature modules — `marks`, `images`, finder/navigation

High leverage. `app/lua/config/commands/init.lua` is 372 lines because it owns UX that should live in feature modules. Specifically:

- `vimoire.marks` only exposes `parse(content)`. The picker UI (`commands/init.lua:62-106`) should move to `marks.browse(bufnr)` and `marks.insert()`.
- `vimoire.images` has full file ops; the 110-line `InsertImage` UX in `commands/init.lua` should move to `images.insert()`.
- `vimoire.finder` builds picker data; `config/commands/navigation.lua` (~200 lines of near-duplicate picker bodies) runs them. Collapse both into `vimoire.navigation.picker` with `picker.manuscript()`, `picker.planning()`, etc.

After this, `commands/init.lua` is ~200 lines of thin dispatchers.

### Structural nested-if audit

Remaining nested-if cases that are NOT type-dispatch in disguise. Examples: `ExportFile.scan_folder` and `Board.scan_folder` (use `plenary.scandir.scan_dir(path, { depth = 1 })` to flatten), any others a codebase sweep surfaces. Dispatch a cartographer-style agent to catalog and propose flattened shapes; tackle as one focused branch.

Doesn't require waiting on composition — these are pure code-quality fixes in orthogonal spots.

