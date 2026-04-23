# Composition Refactor — Working Notes

Staging ground for the data-model refactor of `core/`. See `docs/DESIGN_PRINCIPLES.md` for the duck-typing/composition rule and `~/dev/dewzy/docs/engineering/data_architecture_rationale.md` for the canonical pattern.

## Status (as of 2026-04-23)

**Complete.** All 5 per-kind classes deleted. `core/` now has `kinds.lua` + `item.lua` as the only document-model files. `DocumentBase`, `SectionBase`, and all shim classes are gone. Migration landed on branch `kinds_refactor`, merged to `main`.

**What was planned vs. what happened:** Steps 5 (delete per-kind files) and 6 (inline DocumentBase/SectionBase) merged into one — by the time per-kind files were deleted, `item.lua` already contained everything from both base classes, so there was nothing to inline. The `preserve_notes` construction path (planning_item from chapter delete) was routed through `Item.create` in Step 4a.

## Chosen approach: kinds table

The 5 per-kind classes (`Chapter`, `Page`, `PlanningItem`, `ManuscriptSection`, `PlanningSection`) are configuration entries pretending to be classes. ~50 lines each, mostly setting class constants (`KIND`, `BASE`, `TEXT_FILENAME`, `ADD_OPTIONS`) and tiny methods that return them. The per-class files exist only because Lua's class machinery wraps the data in OO clothing.

**Replace with a data table + one Item class:**

```lua
-- core/kinds.lua
return {
  chapter = {
    base = "entries", text_filename = "prose.md", extras = true,
    numbered = true, toggle_to = "page",
    add_options = { CHAPTER, PAGE, SECTION },
    export_context = function(item)
      return { title = item.name, num = item.chapter_index }
    end,
  },
  page = {
    base = "entries", text_filename = "prose.md", extras = true,
    toggle_to = "chapter",
    add_options = { CHAPTER, PAGE, SECTION },
    export_context = function(item)
      return { title = item.name, actions = {} }
    end,
  },
  planning_item = {
    base = "planning", text_filename = "text.md", extras = false,
    add_options = { PLANNING_ITEM },
    category = "planning",
  },
  section = {
    container = true,
    add_options = { CHAPTER, PAGE, SECTION },
  },
  subfolder = {
    container = true,
    add_options = { PLANNING_ITEM },
    category = "planning",
  },
}
```

`Item` reads from the table for every behavior method:

```lua
function Item:base() return kinds[self.kind].base end
function Item:numbered() return kinds[self.kind].numbered == true end
function Item:text_path()
  local k = kinds[self.kind]
  if not k.text_filename then return nil end
  return self:dir_path() .. "/" .. k.text_filename
end
```

**Net file change:** `core/` collapses from ~9 files (5 kind classes + `document_base` + `section_base` + `entry` + `folder`) to ~3 (`item.lua`, `kinds.lua`, `folder.lua`).

### Why not the hybrid (component-list-per-kind)?

The hybrid frames the units of variation as **behaviors** (`chapter = { Prose, Notes, Numbered, Container }`). That's right when behaviors combine combinatorially in unpredictable ways. Vimoire's actual variation is **configuration-shaped** — each kind picks values for the same handful of slots (text filename, base dir, add-options list, etc.). Components are one indirection past where the data already wants to live.

The kinds table is a stepping stone *to* components if/when the variation grows past what a config table comfortably expresses. Going straight to components is over-engineering for current shape.

### What stays out

`ExportFile`, `Board`, `Book` are genuinely their own things with unique behavior. They don't fit `kinds.lua`. They stay separate. The kinds table is for the document-shaped family only.

## Migration plan

Branch: `kinds_refactor`. Each commit green and ship-able; can stop midway.

1. **Write `core/kinds.lua`.** Distill all 5 per-kind classes into the table. Pure data file, no code changes. Zero risk.
2. **Introduce `core/item.lua`.** One class merging `DocumentBase` + `SectionBase` behavior, reading from `kinds.lua`. Unused. Zero risk.
3. **Switch `Entry.build`.** `Chapter.new(data, root)` returns `Item.new("chapter", data, root)`. Per-class files become 3-line shims. **High risk:** state_spec must pass, manual smoke test required (open project, browse tree, edit chapter, toggle kind, save).
4. **Delete per-kind class files.** Update direct callers (likely few — `Entry.build` is the boundary).
5. **Inline `DocumentBase`/`SectionBase` into `item.lua`.** One file.
6. **Update this doc** with "complete" status.

## Alternative considered: hybrid (component-list-per-kind)

Original 2026-04-20 framing. Kept here as historical context. Sketch:

```lua
local kind_components = {
  chapter = { Prose, Notes, Numbered, Container },
  page    = { Prose, Notes, Container },
  -- etc.
}
```

Adding a kind = one table row + any new components. Class hierarchy collapses to `Item` + component set.

**Why we didn't pick this:** the unit of variation in vimoire's documents isn't behavioral combination — it's configuration values. The kinds-table approach captures the same wins (one Item class, data-level kind addition, one source of truth) with one fewer abstraction layer.

## Diagnosis from the 2026-04-20 sweep

- Zero `if item.kind == "X"` conditionals in behavior code.
- One legitimate kind dispatch at boundary: `core/entry.lua:14` — `KINDS[data.kind] or Page`.
- All other `.kind` uses: presentation routing (icons, highlights, neo-tree `node.type`), construction-time set, or `toggle_kind` rewriting the label. All legitimate.
- Duck-typed shape checks (`if item.items then` — 13 occurrences) are idiomatic per `DESIGN_PRINCIPLES.md`, not smells.
- Structural nested-ifs (scan_folder pyramids, browser closures) are independent of composition. Catalogued in `TODO.md` audit entry.
- Walker duplication (`state.lua:108-151`) is independent of composition — standalone `walk(items, visit_fn)` extraction. Parked in `TODO.md`.
- **Real duplication:** the class hierarchy. `Chapter`, `Page`, `PlanningItem` inherit `DocumentBase` and mostly differ by a `KIND` constant + a few method overrides. `ManuscriptSection` and `PlanningSection` both inherit `SectionBase` with near-identical shape. Five shallow classes where two or three component combinations would suffice.

## Open questions for kinds-table approach

- **`toggle_kind` mechanism.** Current impl: `self:update(state, { kind = "page" })` then `state:load(...)` rebuilds. Under kinds-table: same shape — mutate `kind`, rebuild. Item identity stays; behavior changes via the table lookup. Probably trivial.
- **`extras = true`** on Chapter/Page vs `extras = false` on PlanningItem. Need to read where `extras()` is called to confirm semantics. (Likely the "has notes.md" flag.)
- **`section` vs `subfolder` kind names.** Current code uses both. Confirm both stay distinct or unify. (Probably stay distinct — they have different `add_options`.)
- **`Folder` class.** Synthetic UI containers ("manuscript", "planning", "characters", etc.) constructed in `state.lua:67-100` via `Folder.new`. Stays separate, or absorbed into Item with `container = true, synthetic = true`? Lean toward staying separate for v1 — synthetic folders have a different lifecycle (constructed at rebuild, never persisted to manuscript.json).
- **Where do per-kind methods that aren't pure data go?** `Chapter:export_context` returns a table built from instance state. Lives in `kinds.lua` as a function field — already shown in the example. `Item:export_context()` becomes `kinds[self.kind].export_context(self)`.

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
