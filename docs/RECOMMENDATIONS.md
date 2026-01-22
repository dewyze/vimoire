# Vimoire — Architectural Recommendations

An audit of patterns to preserve, refactor, and replace. Focused on OO design quality, separation of concerns, and eliminating type-checking conditionals.

---

## Current State Summary

The foundation is sound: unified `state.items` registry, polymorphic document interfaces via metatables, duck-typed container detection. The codebase follows its own OO principles consistently.

Recent refactoring completed:
- Shared node factory extracted
- Collector utility for flat item lists
- Export module decomposed (pandoc.lua, template.lua)
- Commands split by domain (export, snippets, navigation)

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

Add options and delete options are tables with `label` and `execute` function. Each class defines its own options as a class constant and returns them via method (`item:add_options()`). No giant switch statements choosing what action to take.

**Why it works:** New options are data, not code changes. The object owns its behavior—caller asks, object answers. Easy to test in isolation.

**Preserve:** Keep options declarative. Don't add conditional logic to option execution.

---

### 6. Navigation as Thin Adapter

Neo-tree sources transform domain items into display nodes. They don't contain business logic—they delegate to domain objects for behavior.

**Why it works:** UI framework is decoupled from domain. Could swap to a different tree view without touching domain code.

**Preserve:** Keep navigation sources thin. Business logic belongs on domain objects.

---

## Notes

### Factory Pattern Exception

**Note:** `Entry.build` uses a kind-to-class map to hydrate items from JSON. This is acceptable.

**Why it's different:** Deserialization requires knowing which class to instantiate. This dispatch happens exactly once per item at load time, not repeatedly during operations. It's a factory, not a behavioral dispatch.

**Keep as-is:** But be aware this is the ONE place kind-based dispatch is legitimate.

---

## Design Principles (Reiterated)

These are already in CLAUDE.md but worth restating as the refactoring filter:

1. **Duck type on behavior, not kind.** Check what it can do, not what it is.

2. **Polymorphic methods over conditionals.** Add a method to the object. Call the method.

3. **Structure IS the type.** If it has `items`, it's a container. No kind checks needed.

4. **Caller asks, object answers.** Never `if kind == X then do_X_thing()`. Always `item:do_thing()`.

5. **Unified state.items map.** Everything indexable lives here. No parallel registries.

If you're about to write a conditional that checks kind, STOP. That's the object's job.
