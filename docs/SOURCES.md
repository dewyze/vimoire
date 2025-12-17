# Neotree Sources Architecture

Multiple dedicated neotree sources for different workflows. Each source is a focused view with its own tree structure, actions, and commands.

## Motivation

When exporting, you don't care about chapters. When plotting, you don't care about export configs. Dedicated views:

- Remove noise, show what matters for the current task
- Make actions first-class (prominent buttons, not nested items)
- Allow workflow-specific keybindings
- Signal "this is a real feature" not "tacked on"

## Design Rationale

Multiple sources is the right abstraction because these represent distinct *modes of work*, not filtered views of the same data:

1. **Manuscript source**: entries + planning (characters, settings, reference) — the "writing" workflow. Planning stays here because you reference character sheets and setting docs frequently while writing.

2. **Export source**: templates, configs, outputs, actions — the "publishing" workflow. Completely separate headspace from writing.

3. **Plotting source** (future): grid/kanban — the "story structure" workflow.

Each source rebuilds its tree on navigate, so there's no state sync complexity. The data dependencies (export depends on manuscript) don't require view dependencies.

## Neo-tree Source API

From reading the neo-tree source code, a source needs:

- `name` — string identifier, used for `:Neotree source=name`
- `display_name` — shown in UI/source selector
- `default_config` — renderers per node type, window config
- `navigate(state, path, path_to_reveal, callback)` — builds and renders the tree
- `setup(config, global_config)` — initialization, event subscriptions

Optional but useful:
- Event subscriptions via `manager.subscribe` for refresh-on-change
- `toggle_directory` for custom expand/collapse behavior
- Source-specific commands

The current vimoire source already has the required API. The refactor is about splitting it, not rewriting it.

## Node Types

All sources share the same node primitives:

```lua
-- Action: executes a function on Enter
{
  id = "run_export",
  name = "Run Export...",
  kind = "action",
  icon = "▸",
  action = function() ... end,
}

-- Folder: has children, toggles on Enter
{
  id = "export_configs",
  name = "Configs",
  kind = "folder",
  icon = "",
  children = { ... },
}

-- File: opens path on Enter
{
  id = "abc123",
  name = "default.yml",
  kind = "file",
  icon = "",
  path = "/path/to/file",
}
```

Skip separator nodes — neo-tree doesn't support non-interactive nodes cleanly. Use icon differentiation and grouping instead.

## Source Structure

Each source is a module that builds a tree and handles navigation:

```lua
-- sources/export/init.lua
function M.navigate(state, path, path_to_reveal, callback)
  local tree = build_tree()
  render(state, tree)
end
```

Sources share command implementations where behavior is identical (open, toggle, close_window). Source-specific commands live in the source directory.

## File Layout

```
navigation/
  neotree_base.lua              -- node builders, shared commands (open, toggle, refresh)
  open.lua                      -- shared file opening logic (unchanged)
  sources/
    manuscript/
      init.lua                  -- writing view (entries + planning)
      commands.lua              -- add, rename, delete, move_up/down, notes
    export/
      init.lua                  -- publishing view (templates, configs, outputs)
      commands.lua              -- run_export, generate_config (if needed)
```

## Export View

Tree structure:

```
Export
  ▸ Generate Config
  ▸ Run Export...
  Templates/
    chapter.md
  Configs/
    default.yml
  Output/
    My Book.epub
    My Book.docx
```

Actions:
- **Generate Config**: Calls `:VimoireExportConfig`, refreshes tree
- **Run Export...**: Opens format picker (EPUB, DOCX), runs export, refreshes Output

Entry points:
- `:VimoireExportView` command
- Keymap (e.g., `gve` — go vimoire export)
- Action node in main tree's Export folder: "Open Export View →"

## Future: Plotting View

Same pattern for story structure work:

```
Plotting
  ▸ Open Grid View
  ▸ Open Kanban
  Plotlines/
    ...
  Arcs/
    ...
```

Plotting is a distinct workflow from writing — you're thinking about structure, not prose.

## Switching Between Sources

Options:
1. **Commands**: `:VimoireTree`, `:VimoireExportView`, `:VimairePlanningView`
2. **Keymaps**: `gvm` (manuscript), `gve` (export), `gvp` (planning)
3. **Source selector**: Neo-tree's built-in tab bar (may feel heavy)

Recommendation: Commands + keymaps. Keep it simple.

## Decisions

**Separators**: Skip them. Icon differentiation and grouping is enough.

**Source selector tab bar**: Skip it. Keymaps are simpler and we dynamically set `display_name` for the book title.

**Refreshing across sources**: Non-issue. Each source rebuilds on navigate. No shared state to sync.

**Entry node in main tree**: Yes, add "Open Export View →" action in Export folder for discoverability.

**Back navigation**: Just use keymaps. `gvm` for manuscript, `gve` for export. No toggle behavior, no back button.

## Refactoring Required

The current source is well-structured. Changes needed:

1. **Extract node builders** — `node_from_item`, `build_items_nodes`, `build_planning_items` move to `neotree_base.lua`. Both sources use these.

2. **File reorganization** — Current `neotree_source/` becomes `sources/manuscript/`. New `sources/export/`.

3. **Add action node handling** — Current `commands.open` checks `text_path()`. Add check for `action` function and call it. This is the main new capability.

4. **Split commands** — Manuscript-specific (add, rename, delete, move_up/down) stay with manuscript. Export-specific (run_export, generate_config) go with export. Shared (toggle, close_window, refresh) go in base.

**Not needed:**
- Async loading (data's in memory)
- Event subscriptions (nice-to-have, not critical)
- Major architectural changes

## Implementation Order

1. Extract shared base (node builders, common commands) to `neotree_base.lua`
2. Move current source to `sources/manuscript/`, update imports
3. Add action node type support to shared `open` command
4. Build export source using same patterns
5. Add switching commands/keymaps (`gvm`, `gve`)
6. Remove Export folder from manuscript source (it moves to its own view)
7. (Later) Plotting source when we build that phase
