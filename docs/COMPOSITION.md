# Composition Refactor — Working Notes

Staging ground for the "composition over classification" refactor. See `docs/DESIGN_PRINCIPLES.md` for the rule and `~/dev/dewzy/docs/engineering/data_architecture_rationale.md` for the canonical pattern.

## Status (as of 2026-04-20)

**Parked, pending audit and walker dedup.** Nested-if audit catalog and `state.lua` walker dedup are both in `TODO.md` and should land first — they either remove composition's arguments or cleanly compose with them. Reassess composition after those land.

Preferred shape **if** composition proceeds: **hybrid** (below), not full composition. The distinction matters because the original full-composition pitch assumed scattered `kind ==` checks that we confirmed don't exist.

## The shape (hybrid, preferred)

`kind` stays in the JSON as a stable label. A central `kind_components` table at construction maps kind → components. Inside the code, behavior is component-driven:

```lua
local kind_components = {
  chapter = { Prose, Notes, Numbered, Container },
  page    = { Prose, Notes, Container },
  section = { Container },
  planning_item = { ... },
  -- etc.
}
```

Adding a new kind = one table row + any new components that don't already exist. Class hierarchy collapses to a single `Item` class plus the component set.

### What this buys

- Class hierarchy collapses (5 core classes → 1 `Item` + components).
- Adding a new kind is a data-level change — one table row.
- Cross-cutting behavior changes live in one component, not scattered across class methods.
- Config-driven registration (the `kind_components` table) reads like neo-tree / snacks config, which is where the "disciplined feel" of those libraries comes from.

### What it does NOT buy (calibration for future sessions)

- **Scattered kind-check cleanup** — doesn't apply. 2026-04-20 sweep confirmed zero `if item.kind == "X"` conditionals in behavior code.
- **"Disciplined feel"** — helps, but isn't the whole answer. Module-boundary discipline (commands/init.lua cleanup landed during 2026-04-19/20 session) and the nested-if audit move that needle more per unit effort.
- **Kind-specific change ergonomics** — slightly worse, not better. Today editing Chapter.lua is one file; under hybrid you navigate "Chapter = [Prose, Notes, Numbered, Container] — which component owns this?" Offset by wins on cross-cutting changes, which are rarer.

## Diagnosis from the 2026-04-20 sweep

- Zero `if item.kind == "X"` conditionals in behavior code.
- One legitimate kind dispatch at boundary: `core/entry.lua:14` — `KINDS[data.kind] or Page`.
- All other `.kind` uses: presentation routing (icons, highlights, neo-tree `node.type`), construction-time set, or `toggle_kind` rewriting the label. All legitimate.
- Duck-typed shape checks (`if item.items then` — 13 occurrences) are idiomatic per `DESIGN_PRINCIPLES.md`, not smells.
- Structural nested-ifs (scan_folder pyramids, browser closures) are independent of composition. Catalogued in `TODO.md` audit entry.
- Walker duplication (`state.lua:108-151`) is independent of composition — standalone `walk(items, visit_fn)` extraction. Parked in `TODO.md`.
- **Real duplication:** the class hierarchy. `Chapter`, `Page`, `PlanningItem` inherit `DocumentBase` and mostly differ by a `KIND` constant + a few method overrides. `ManuscriptSection` and `PlanningSection` both inherit `SectionBase` with near-identical shape. Five shallow classes where two or three component combinations would suffice.

## Design doc checklist (fill in during prep)

- [ ] Audit matrix: rows = current classes, columns = behaviors (Prose, Notes, Container, Numbered, Immutable, FilesystemBacked, ExternalOpener, VirtualPath, Preservable). Populate cells honestly.
- [ ] Derive component set from the matrix. Names, responsibilities, interactions.
- [ ] Runtime representation: how does `Item` construct from data + the kind→components lookup? Factory + per-component init? Metatable composition? Stick with Lua idiom; don't invent framework machinery.
- [ ] `toggle_kind` handling: current impl mutates `self.kind` in place; under hybrid, kind change = swap component set. Decide the mechanism.
- [ ] Class-by-class migration path (phases). Each phase must land on dev, self-contained, with a rollback gate. Halfway state is worst state.
- [ ] Test strategy (per-component + per-kind integration).
- [ ] Migration of existing `manuscript.json` files: trivial under hybrid (kind already on disk), but confirm no renames are needed.

## Notes accumulated along the way

### `:action()` is a classification-era hook — composition will eliminate it

Surfaced while fixing the ExportFile binary-open bug (branch `export_file_binary_dispatch`, 2026-04-19).

Every item class has `:action()`. Only `ExportFile` and `ActionItem` do real work. `DocumentBase:action()` and `Book:action()` return `false` after the bug fix (was dead `vim.cmd.edit` before). `SectionBase:action()` and `Folder:action()` return `false` as sentinels so the navigator falls through to toggle.

Under composition, "what does Enter do?" becomes a component lookup:

- TextContent → neo-tree's window-managed edit
- FilesystemBacked + binary extension → external opener (`vim.ui.open` / `open`)
- Action → run stored fn
- Container alone → toggle expand
- Virtual path (Board's `vimoire://`) → delegate to `BufReadCmd`

The four sentinel `:action()` methods on `DocumentBase`, `Book`, `SectionBase`, `Folder` vanish under composition — they exist only because classification requires every class to participate in the dispatch protocol.

### ExportFile's construction-time action attachment is composition in miniature

Same fix session. `ExportFile.new` attaches an `:action` lambda to the instance **only when the path has a binary extension** (pdf/epub/docx/mobi). Templates and configs get no `:action`, so the navigator's path branch routes them through `cc.open` naturally.

This is the shape composition will generalize: `ExportFile` becomes a generic `Item` carrying `FilesystemBacked` + an optional `ExternalOpener` component. The scan-time decision "is this binary?" becomes "attach `ExternalOpener`?". Same boundary-time dispatch, different data model.

Canonical example of the construction-time attachment pattern before we have proper components.

## Open questions

- Synthetic folders (planning, characters, reference) — `Container` + `Immutable`, no `Prose`? What holds their `add_options`?
- `DocumentBase:destroy` silently creates a planning item from notes on delete. Is `Preservable` its own component, or tied to `Notes`?
- Component set boundary: what's a real component vs a cross-cutting concern that stays outside the component system (e.g. `chapter_index` numbering state — component data or separate)?
- `Board`'s virtual path (`vimoire://plotting/<id>`) — a `VirtualPath` component, or `FilesystemBacked` with a virtual scheme flag?
