# Vimoire — Architectural Recommendations

An audit of patterns to preserve, refactor, and replace. Focused on OO design quality, separation of concerns, and eliminating type-checking conditionals.

---

## Current State Summary

The foundation is sound: unified `state.items` registry, polymorphic document interfaces via metatables, duck-typed container detection. Approximately 80% of the codebase follows its own OO principles.

The contamination is concentrated:
- View config coupled into state management
- Type-checking conditionals in 3-4 locations
- Duplicate tree-walking logic across modules
- Two god objects that do too much

---

## Patterns to Preserve

### 1. Unified State Registry

All items live in `state.items` keyed by ID. No parallel maps, no type-prefixed IDs, no separate registries for different item kinds. Lookups are O(1) by ID.

**Why it works:** Single source of truth. Any code that needs an item goes through one access point. No synchronization bugs between parallel structures.

**Preserve:** This is load-bearing. All future features should use `state.items` exclusively.

---

### 2. Polymorphic Document Interface

Items respond to methods: `display_name()`, `text_path()`, `notes_path()`, `destroy()`, `toggle()`. Callers invoke the method; objects decide how to respond. Chapters return numbered names, pages don't—that's the object's responsibility.

**Why it works:** New item types only need to implement the interface. Calling code never changes. No switch statements on kind.

**Preserve:** Extend this pattern to any new behaviors needed.

---

### 3. Duck-Typed Container Detection

Code checks `if item.items then` to detect containers, not `if item.kind == "section"`. The structure IS the type. If it has an `items` array, it's a container.

**Why it works:** Any new container type automatically works everywhere. No registration, no special-casing.

**Preserve:** Never check kind to determine if something is a container.

---

### 4. Metatable Inheritance

Classes use `setmetatable(Class, { __index = BaseClass })` for inheritance. `DocumentBase` provides shared behavior; `Chapter`, `Page`, `PlanningItem` extend it.

**Why it works:** Idiomatic Lua. Clear inheritance chain. Shared behavior lives in one place.

**Preserve:** Continue using this pattern for new item types.

---

### 5. Options as Data Structures

Add options and delete options are tables with `label` and `execute` function. The view config attaches appropriate options to items at construction. No giant switch statements choosing what action to take.

**Why it works:** New options are data, not code changes. Easy to test in isolation.

**Preserve:** Keep options declarative. Don't add conditional logic to option execution.

---

### 6. Navigation as Thin Adapter

Neo-tree sources transform domain items into display nodes. They don't contain business logic—they delegate to domain objects for behavior.

**Why it works:** UI framework is decoupled from domain. Could swap to a different tree view without touching domain code.

**Preserve:** Keep navigation sources thin. Business logic belongs on domain objects.

---

## Patterns to Refactor

### 1. View Config Coupling

**Current:** `state.lua` applies view configuration (icons, highlights, add_options) directly to domain objects during rebuild. Domain objects carry presentation data.

**Problem:** Mixing concerns. Domain objects shouldn't know about icons. Forces a kind-based lookup during every rebuild.

**Recommendation:** View properties should be resolved at render time by the component, not attached to domain objects. Two approaches:

- **Class constants:** Define `icon`, `highlight` as constants on each class. No lookup table needed.
- **Render-time resolution:** Components query a view config by item kind when rendering, not when building state.

`add_options` is a special case—it's behavior, not presentation. Consider making it a method on items (`item:add_options()`) or defining it as a class constant.

---

### 2. Export Module Decomposition

**Current:** `export/init.lua` is 290 lines handling template resolution, file preparation, pandoc argument building, export execution, and config-based exports.

**Problem:** Untestable monolith. Can't test template discovery without running exports. Can't test argument building without file I/O.

**Recommendation:** Extract into focused modules:
- `export/templates.lua` — Template discovery, loading, validation
- `export/pandoc.lua` — Argument building, command execution
- `export/init.lua` — Orchestrator that composes the above

Each module should be testable in isolation.

---

### 3. Duplicate Node Factory

**Current:** Both manuscript and export navigation sources define their own `node_from_item` function with identical logic.

**Problem:** Duplication. Changes need to happen in two places.

**Recommendation:** Extract to `navigation/node_factory.lua`. Single function that transforms domain items to neo-tree nodes. All sources import and use it.

---

### 4. Tree Walking Consolidation

**Current:** Multiple modules walk the item tree independently:
- `state.rebuild()` walks to apply view config and indexing
- Telescope extension walks to build flat entry lists
- Export source walks to collect exportable items

**Problem:** Same traversal logic reimplemented in different ways. Divergence risk.

**Recommendation:** Provide a collector pattern on state or as a utility:
- `state:collect(filter_fn)` — Returns flat list of items matching filter
- Or `collector.collect(items, filter_fn)` — Standalone utility

Telescope, export, and other consumers use this instead of rolling their own walks.

---

### 5. Command File Growth

**Current:** `commands.lua` is 434 lines containing all user commands. Growing unboundedly.

**Problem:** God file. Hard to navigate. Unrelated commands mixed together.

**Recommendation:** Group commands by domain:
- `commands/export.lua` — Export-related commands
- `commands/snippets.lua` — Snippet commands
- `commands/navigation.lua` — Navigation and tree commands
- `commands/init.lua` — Composes all command modules

Not urgent, but prevents future pain.

---

## Patterns to Eliminate

### 1. Type-Checking Conditionals

**Current:** Several locations check `item.kind` or `node.type` to determine behavior:
- Statusline checks kind to determine context color
- State rebuild checks kind to assign chapter indices
- Components check type for special rendering

**Problem:** Violates OO principles. Caller decides behavior instead of object. Adding new types requires changing calling code.

**Recommendation:** Replace each with a method the object implements:

| Instead of | Use |
|------------|-----|
| `if item.kind == "chapter"` for numbering | `item:numbered()` returns boolean |
| `if item.kind == "planning_item"` for context | `item:context()` returns context key |
| `if item.kind == "section"` for container check | `if item.items then` (already correct elsewhere) |

The caller asks, the object answers. New types implement the method; calling code never changes.

---

### 2. View Config as Type Dispatch

**Current:** `view_config` table maps kind strings to presentation properties. State rebuild iterates and applies based on `item.kind`.

**Problem:** It's a switch statement wearing a table costume. Same fundamental issue as type-checking conditionals.

**Recommendation:** Define view properties on classes:

```lua
Chapter.icon = icons.CHAPTER
Chapter.highlight = "VimoireChapter"
```

Or use a method:

```lua
function Chapter:view_config()
  return { icon = icons.CHAPTER, highlight = "VimoireChapter" }
end
```

The config is on the class, not in an external lookup table.

---

### 3. Factory Pattern Exception

**Note:** `Entry.build` uses a kind-to-class map to hydrate items from JSON. This is acceptable.

**Why it's different:** Deserialization requires knowing which class to instantiate. This dispatch happens exactly once per item at load time, not repeatedly during operations. It's a factory, not a behavioral dispatch.

**Keep as-is:** But be aware this is the ONE place kind-based dispatch is legitimate.

---

## Priority Order

Ordered by dependency—earlier phases establish patterns that later phases build on.

### Phase 1: View Pattern Foundation

**Move view properties to classes** — Define icon/highlight as class constants. Eliminates view_config lookup pattern. This is the foundational architectural change; everything else builds on it.

### Phase 2: Polymorphic Methods

These can be done in any order, but do them after Phase 1 to maintain the "properties and methods live on classes" pattern throughout.

1. **Add `context()` method to item classes** — Eliminates statusline type checks.

2. **Add `numbered()` method to document classes** — Chapters return true, pages return false. Eliminates kind check in indexing.

### Phase 3: Consolidation

Depends on Phase 1. These extract shared code using the patterns established above.

3. **Extract shared node factory** — Single module for item-to-node transformation. Uses class-based view properties.

4. **Add collector utility for flat item lists** — Telescope and export reuse instead of reimplementing walks.

### Phase 4: Decomposition

Independent of other phases. Can be done anytime, but lower priority.

5. **Decompose export module** — Extract templates.lua and pandoc.lua. Improves testability.

6. **Split commands.lua by domain** — Organizational improvement. Not urgent but prevents future pain.

---

## Design Principles (Reiterated)

These are already in CLAUDE.md but worth restating as the refactoring filter:

1. **Duck type on behavior, not kind.** Check what it can do, not what it is.

2. **Polymorphic methods over conditionals.** Add a method to the object. Call the method.

3. **Structure IS the type.** If it has `items`, it's a container. No kind checks needed.

4. **Caller asks, object answers.** Never `if kind == X then do_X_thing()`. Always `item:do_thing()`.

5. **Unified state.items map.** Everything indexable lives here. No parallel registries.

If you're about to write a conditional that checks kind, STOP. That's the object's job.
