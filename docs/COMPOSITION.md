# Composition Refactor — Working Notes

Staging ground for the "composition over classification" refactor. See `docs/DESIGN_PRINCIPLES.md` for the rule and `~/dev/dewzy/docs/engineering/data_architecture_rationale.md` for the canonical pattern.

Scratch file. Becomes the formal design doc once the audit and component set settle.

## The shape

Replace `kind`-based class hierarchy with a single `Item` core + optional behavior components. Data in manuscript.json describes which components an item carries; code checks component presence, not class identity.

## Design doc checklist (to fill in)

- [ ] Audit current item classes and the behaviors each bundles
- [ ] Propose the component set and responsibilities
- [ ] Class-by-class migration path (≥5 phases; no halfway stop)
- [ ] Data migration plan for existing manuscript.json files
- [ ] Test strategy (per-component + composition)
- [ ] Rollback plan per phase

## Notes accumulated along the way

### `:action()` is a classification-era hook — composition will eliminate it

Surfaced while fixing the ExportFile binary-open bug (branch `export_file_binary_dispatch`, 2026-04-19).

Every item class has `:action()`. Only `ExportFile` and `ActionItem` do real work. `DocumentBase:action()` and `Book:action()` return `true` after a `vim.cmd.edit` that is dead code under current navigator ordering (the `node.path → cc.open` branch wins first). `SectionBase:action()` and `Folder:action()` return `false` as sentinels so the navigator falls through to toggle.

Under composition, "what does Enter do?" becomes a component lookup:

- TextContent → neo-tree's window-managed edit
- FilesystemBacked + binary extension → external opener (`vim.ui.open` / `open`)
- Action → run stored fn
- Container alone → toggle expand
- Virtual path (Board's `vimoire://`) → delegate to BufReadCmd

The four sentinel/dead `:action()` methods on `DocumentBase`, `Book`, `SectionBase`, `Folder` vanish under composition — they exist only because classification requires every class to participate in the dispatch protocol. No separate cleanup needed first; composition absorbs them.

### ExportFile's construction-time action attachment is composition in miniature

Same fix session. `ExportFile.new` now attaches an `:action` lambda to the instance *only when the path has a binary extension* (pdf/epub/docx/mobi). Templates and configs get no `:action`, so `node_from_item` sets `extra = nil`, and the navigator's path branch routes them through `cc.open` naturally.

This is the shape composition will generalize: under the refactor, `ExportFile` disappears and becomes a generic `Item` carrying a `FilesystemBacked` component plus an optional `ExternalOpener` component. The scan-time decision "is this binary?" becomes "attach `ExternalOpener` component?". Same boundary-time dispatch, different data model. The current `ExportFile.new` body will be replaced outright.

Keeping this note as the canonical example of what the construction-time attachment pattern looks like before we have proper components.

## Open questions

- Synthetic folders (planning, characters, reference) — Container + Immutable, no TextContent?
- `DocumentBase:destroy` silently creates a planning item from notes. Is "Preservable" its own component, or tied to NotesContent?
- Biggest risk: stopping halfway. Staging must commit to completion.
