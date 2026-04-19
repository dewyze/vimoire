# Design Principles

Rules that guide how Vimoire is built. Reference when making architectural decisions or reviewing refactors. This is the canonical source; other docs (including the LLM-facing `.claude/CLAUDE.md`) should point here rather than duplicate.

## Duck type on behavior, not kind

Don't check `item.kind == "section"`. Check what it can do: `if item.items then` (it's a container), `if item:text_path()` (openable). The structure IS the type.

## Polymorphic methods over conditionals

All items respond to `display_name()`, `text_path()`, `destroy()`. Call the method, let the object decide what to do. Chapters return numbered names, pages don't — that's the object's job, not the caller's.

## Never write type-checking conditionals

If you're about to write `if is_section(item)` or `if item.kind == "foo"` or `if item.id == "manuscript"`, **stop**. That's the object's job. Add a method to the object instead. The caller asks, the object answers. No exceptions.

The one legitimate place to inspect data shape is the boundary between raw JSON and objects — `Entry.build(data, root)` has to decide what class to construct. Even there, prefer table dispatch on a self-describing field to ladder-style `if` chains.

## Unified `state.items` map

Everything indexable lives in `state.items` with its ID as key — entries, sections, folders, planning items, subfolders. No separate maps, no type prefixes.

## No encoded IDs

IDs are unique 6-char alphanumeric strings. Never construct IDs like `"char:" .. id` or `"characters:" .. name`. If you need to look something up, it has a proper ID. If it's a scanned filesystem artifact without a user-managed ID, find another abstraction.

## Common interface

All items in `state.items` have: `id`, `name`, `immutable` (boolean), `:destroy(state)`, `:add_options()`, `:add_parent_items()`, `:add_index()`. Many also have `:display_name()`, `:text_path()`. Containers have `items` array.

## Static vs dynamic behavior

Static behavior (doesn't depend on runtime state) is configured at construction — e.g., add options are passed via `opts.add_options` in `state.lua`. Dynamic behavior (depends on current state) is derived at call time — e.g., delete options check `#items > 0` to decide between `KEEP_CONTENTS` and `DELETE`.

## Composition over classification

When variants multiply, prefer a thin core item with optional behavior components attached, over a class hierarchy keyed on a `kind` string.

**The rule:** data should describe what an item IS (`prose: true, notes: true, numbered: true`), not route to a class via a `kind` lookup. Behavior emerges from the PRESENCE of components, not from class identity. An item can carry multiple behaviors simultaneously — the component IS the type.

**Why:** every time we've added a new variant by adding a new class with "some subset of behaviors," we've duplicated work and created a dispatch smell. Composition makes new variants data-level (a new combination of existing components), not code-level (a new class).

**In practice:**
- Data shape: `{ id, name, prose: true, notes: true, numbered: true, items: [...] }`, NOT `{ id, name, kind: "chapter" }` that then routes to a Chapter class which bundles those behaviors.
- Code: `if item.text_content then item.text_content:open() end`, NOT `if item:is_a?(Chapter) or item:is_a?(Page) then ...`.
- Iteration: walk items filtered by the component they carry (`items.with(TextContent)`), not by class.

**When overkill:** tiny hierarchies (2-3 shallow classes), behaviors everyone has (make them first-class), or no variant-explosion pressure. Composition earns its keep when combinations proliferate.

**Canonical reference for the pattern:** `~/dev/dewzy/docs/engineering/data_architecture_rationale.md`. We steal the same lens here.

## Applying these principles

These aren't aspirations — they're enforced. When reviewing code (yours or an LLM's), check for violations in this order:

1. Is there a type-checking conditional? Replace with polymorphism or composition.
2. Is there a class hierarchy where classes differ only in which behaviors they bundle? Consider composition.
3. Is data routing through a `kind` field to pick a class? See if the data could self-describe instead.
4. Is an ID constructed from other strings? That's an abstraction smell — find the real ID or the real missing model.
5. Do two items of different "kinds" have nearly-identical methods? They probably want the same behavior component.
