# Container/Document Split — Working Notes

Picked up cold? Read this top-to-bottom before writing any code.

## What this refactor does

`item.lua` currently has one `Item` class that handles two structurally different things:

- **Document items** (`chapter`, `page`, `planning_item`): have files on disk, paths, notes, file-based destroy
- **Container items** (`section`, `subfolder`): named groups with an `items` array, no files, no paths

These two roles are currently unified in one class with ~10 `if self:container() then` branches throughout. This refactor splits them into two metatables: `DocumentItem` and `ContainerItem`. The branches disappear — each class only has the methods that apply to it.

## The section/subfolder question (decide first)

Before touching any code, settle this:

`section` and `subfolder` are currently two separate entries in `kinds.lua`, but they have identical structure — both `container = true`, same movement behavior, same tree mechanics. The only differences are `category` (prose vs. planning) and `add_options` (what children they accept).

**Option A — keep them as two named kinds (recommended)**

`kinds.lua` stays as-is. `section` and `subfolder` remain distinct. The names are useful (they describe where in the manuscript they live), and the `add_options` difference is meaningful config, not duplication. Two container kinds, one ContainerItem class.

**Option B — merge into one `container` kind**

Collapse to one entry in `kinds.lua`. Problem: `manuscript.json` has `"kind": "section"` and `"kind": "subfolder"` in actual data files — merging requires a data migration or a mapping layer. Net negative. Not recommended.

**Decision:** go with Option A. The class split is the win; the kinds.lua consolidation is not worth the migration cost.

## Current container branches in item.lua

Every `self:container()` call is a site that moves to one class or the other:

| Line | Method | Container does | Document does |
|------|--------|---------------|---------------|
| 19 | `Item.new` | copies all data fields, ensures `items = {}` | copies only `id`, `name` |
| 38 | `Item.create` | inserts raw data table, no mkdir | mkdirs, writes frontmatter |
| 86 | `dir_path` | returns nil | returns `root/base/id` |
| 104 | `display_number` | returns nil | returns chapter_index string |
| 109 | `display_name` | returns plain name | prepends chapter number if present |
| 130 | `add_parent_items` | returns `self.items` | returns `self.parent_items` |
| 135 | `add_index` | returns 1 | finds index in parent_items + 1 |
| 162 | `update` | iterates `parent_items` by index | iterates `parent_items` by id match |
| 192 | `destroy_children` | only containers have this | no-op |
| 201 | `preserve_notes` | returns early (no notes) | moves notes.md to orphaned_notes |
| 218 | `destroy` | removes from parent_items, no file delete | preserve_notes then rm -rf dir_path |
| 247 | `promote_children` | only containers have this | no-op |

## Implementation plan

### Step 1 — Split the construction functions

In `item.lua`, change `Item.new` and `Item.create` to return the right metatable:

```lua
local DocumentItem = {}
DocumentItem.__index = DocumentItem

local ContainerItem = {}
ContainerItem.__index = ContainerItem

local Item = {}

function Item.new(kind, data, root)
  if kinds[kind].container then
    local self = setmetatable({}, ContainerItem)
    for k, v in pairs(data) do self[k] = v end
    self.items = self.items or {}
    self.kind = kind
    self.root = root
    return self
  end
  local self = setmetatable({}, DocumentItem)
  self.id = data.id
  self.name = data.name
  self.kind = kind
  self.root = root
  return self
end

function Item.create(kind, state, name, parent_items, at_index)
  -- dispatch to ContainerItem.create or DocumentItem.create
end
```

### Step 2 — Move methods to the right class

**ContainerItem only** (remove container guard, just the method body):
- `dir_path` → not defined (or returns nil, but callers already check)
- `display_number` → not defined
- `display_name` → just `return self.name`
- `add_parent_items` → `return self.items`
- `add_index` → `return 1`
- `update` → the index-based path only
- `destroy_children` → move as-is (remove the `if not self:container()` guard)
- `preserve_notes` → not defined
- `destroy` → the no-file-delete path only
- `promote_children` → move as-is (remove the guard)

**DocumentItem only**:
- `dir_path` → the `root/base/id` path
- `text_path`, `notes_path` → as-is
- `display_number`, `display_name` → the numbered variants
- `add_parent_items` → `return self.parent_items`
- `add_index` → the find-index path
- `update` → the id-match path
- `preserve_notes`, `destroy` → the file-aware paths
- `destroy_children` → not defined (documents don't have children)
- `promote_children` → not defined

**Both classes** (identical implementation, define on both):
- `container()` — ContainerItem always returns true, DocumentItem always returns false
- `base()`, `extras()`, `category()`, `numbered()`, `add_options()`, `export_context()`, `toggle()`, `action()` — identical, delegate to kinds table

### Step 3 — Update Item.create

```lua
function Item.create(kind, state, name, parent_items, at_index)
  local new_id = id_util.generate(state.items)
  local config = kinds[kind]
  if config.container then
    table.insert(parent_items, at_index, { id = new_id, kind = kind, name = name, items = {} })
  else
    local doc_dir = Path:new(state.manuscript.root, config.base, new_id)
    doc_dir:mkdir({ parents = true })
    local text_file = Path:new(doc_dir:absolute(), config.text_filename)
    text_file:write(string.format("---\ntitle: %s\n# subtitle: \n# epigraph: \n---\n\n", name), "w")
    table.insert(parent_items, at_index, { id = new_id, name = name, kind = kind })
  end
  state:save()
  return state.items[new_id]
end
```

### Step 4 — Tests

Run `bin/test` after each step. The existing `entry_spec`, `state_spec`, and `delete_options_spec` cover the key behaviors — no new tests needed unless something unexpected surfaces.

The parity spec was deleted when the old per-kind classes were removed, so there's no "compare old vs new" safety net here. Rely on the integration tests and manual smoke (create chapter, create section, move items, delete chapter with notes).

## Risk

Low. The behavior doesn't change — only the dispatch mechanism. The main mistake to avoid is accidentally giving DocumentItem a method that ContainerItem then calls on a child during `destroy_children`. Read `destroy_children` carefully when you split it.

## Files to touch

- `app/lua/vimoire/core/item.lua` — the whole refactor lives here
- No other files change; callers don't know or care which subtype they have

## What stays the same

- `kinds.lua` — untouched
- `entry.lua` — untouched
- `state.lua` — untouched
- All callers — they call `item:method()` regardless of which subtype
