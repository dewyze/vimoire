# Snacks.nvim Evaluation for Vimoire

Evaluation of [folke/snacks.nvim](https://github.com/folke/snacks.nvim) for potential integration.

---

## Executive Summary

Snacks is a "Swiss army knife" plugin from Folke (lazy.nvim author) that bundles 30+ utilities. Several features align well with Vimoire's needs:

| Priority | Feature | Replaces / Adds |
|----------|---------|-----------------|
| **High** | zen | NEW - distraction-free writing, solves text centering problem |
| **High** | picker | Telescope - 50+ sources, custom finders, ui_select |
| **High** | input | vim.ui.input - floating prompts |
| **Medium** | dashboard | dashboard.lua - maybe, needs testing |
| **Medium** | notifier | NEW - pretty notifications |
| **Medium** | image | NEW - inline images (terminal-dependent) |
| **Low** | scroll | NEW - smooth scrolling |
| **Skip** | dim | Code-focused, not prose-aware |
| **Skip** | explorer | "Picker in disguise", keep neo-tree |

---

## High Priority Features

### Zen Mode - Solves the Text Centering Problem

**The problem:** Text centering was deferred because no-neck-pain uses padding buffers that conflict with neo-tree's layout model.

**Zen mode approach:** Creates a centered floating window with backdrop over the entire screen. This is fundamentally different - it doesn't try to add padding within the existing layout; it floats above it.

```lua
-- Toggle zen mode while writing
Snacks.zen()

-- What it does:
-- 1. Opens current buffer in centered floating window
-- 2. Dims/hides everything behind it (backdrop)
-- 3. Optionally hides statusline, tabline
-- 4. Restores original state on close
```

**Why this might work:** Since it's a float overlay, neo-tree and the normal layout are untouched underneath. No padding buffer gymnastics.

**Configuration:**
```lua
Snacks.setup({
  zen = {
    toggles = {
      dim = false,        -- dim uses code-scope detection, not useful for prose
      git_signs = false,
      diagnostics = false,
    },
    show = {
      statusline = false,
      tabline = false,
    },
    win = {
      backdrop = { transparent = false, blend = 40 },
      width = 80,  -- prose line width
    },
  },
})
```

**Verdict:** Worth prototyping. Could finally deliver centered prose editing.

---

### Picker - Telescope Replacement

Snacks picker has 50+ built-in sources and can fully replace Telescope.

**Built-in sources include:**
- files, grep, git_files, git_status, git_branches
- buffers, recent, marks, jumps, qflist
- lsp_symbols, lsp_references, diagnostics
- commands, keymaps, help, colorschemes
- **ui_select** - replaces vim.ui.select

**Custom picker API:**
```lua
-- Equivalent to current Telescope vimoire extension
Snacks.picker({
  title = "Navigate",
  items = build_all_entries(),  -- your existing function
  format = function(item)
    return { { item.display_number, "Number" }, " ", item.name }
  end,
  confirm = function(picker, item)
    open.open_item(state.items[item.id])
  end,
})
```

**Migration effort:** Medium. The Telescope extension is ~240 lines. Snacks picker API is similar but not identical - would need rewrite, not just config changes.

**Verdict:** Can replace Telescope entirely. Decide if migration is worth the effort vs keeping telescope.

---

### Input - vim.ui.input Upgrade

Drop-in replacement for vim.ui.input with floating windows.

```lua
Snacks.setup({
  input = { enabled = true },  -- globally replaces vim.ui.input
})
```

**Current vim.ui.input calls in Vimoire:**
- `create_project_at()` - project folder name, book title
- Various rename prompts

**Verdict:** Easy win. Enable it and all inputs get prettier with zero code changes.

---

## Medium Priority Features

### Dashboard - Start Screen Replacement?

Snacks dashboard is declarative with sections for headers, recent files, custom actions.

**Current dashboard.lua has:**
- Custom ASCII logo with stars
- Recent projects with dates and paths
- j/k navigation with visual selection
- Actions (n=new, b=browse, q=quit)

**Dashboard capabilities:**
- ASCII headers
- Recent files (built-in)
- Custom sections with actions
- Keybindings

**Concerns:**
- Can it show "recent projects" (directories) vs "recent files"?
- Can it replicate the j/k selection with visual highlighting?
- How much custom lua is needed vs declarative config?

**Verdict:** Needs prototyping. Current dashboard.lua is 350 lines but well-understood. Snacks dashboard might be simpler OR might require fighting the abstraction.

---

### Notifier - Notifications

Pretty floating notifications for vim.notify.

**Use cases in Vimoire:**
- "Export complete: manuscript.epub"
- "Project created: My Novel"
- Error messages
- Auto-save confirmations (if added)

```lua
Snacks.setup({
  notifier = {
    enabled = true,
    timeout = 3000,
    style = "compact",  -- or "minimal", "fancy"
  },
})

-- Usage
vim.notify("Export complete!", vim.log.levels.INFO)
-- or
Snacks.notify.info("Export complete!")
```

**Verdict:** Easy addition. Nice polish for user feedback.

---

### Image - Inline Images

Renders images inline in markdown buffers using Kitty Graphics Protocol.

**Supported terminals:** Kitty, Ghostty, Wezterm (limited)
**Not supported:** Standard Terminal.app, iTerm2 (without config), Zellij

**Relevance to Vimoire:**
- Deferred feature: "Image management (assets folder, insertion workflow)"
- Could show cover art, reference images inline in planning docs
- Character portraits in character files

**Limitations:**
- Terminal-dependent (Neovide uses its own rendering)
- Requires ImageMagick for non-PNG formats

**Verdict:** Cool feature but limited audience. Worth enabling if using supported terminal; gracefully degrades otherwise.

---

## Low Priority / Skip

### Scroll - Smooth Scrolling

Animated scrolling. Nice for prose reading but minor polish.

**Verdict:** Enable if you want it. Low effort, low impact.

---

### Dim - NOT Prose-Aware

Dims code outside current scope using treesitter/indent detection.

**Problem for Vimoire:** Scope detection is designed for code blocks (functions, classes, if statements), not prose paragraphs. Markdown doesn't have the same structural cues.

**Verdict:** Skip. Won't work well for prose editing.

---

### Explorer - Keep Neo-tree

Snacks explorer is "a picker in disguise" - good for fuzzy file selection, not hierarchical tree navigation.

Vimoire's manuscript tree (neo-tree) is purpose-built for:
- Displaying chapters in order (not alphabetical)
- K/J reordering
- Section containers
- Context-aware actions (add chapter vs add character)

**Verdict:** Keep neo-tree. Explorer solves a different problem.

---

### Scratch - Not a Snippets Replacement

Auto-saving scratch buffers per project/branch. Good for quick notes.

**Vimoire's snippets** are structured JSON with:
- Per-chapter storage
- Extractable from text selection
- Planned panel UI

Scratch is just temporary buffers, not a structured snippet system.

**Verdict:** Skip for snippets. Could add as separate "quick notes" feature if desired.

---

## Snippets Investigation

Snacks doesn't have a snippets feature that matches Vimoire's needs. The snippets system (snippets.json per chapter, extractable from selection) is domain-specific.

**Options:**
1. Keep building custom snippets UI as planned
2. Look at other snippet plugins (LuaSnip, etc.) - but these are code snippet expanders, not prose card systems

**Verdict:** Custom implementation remains the right approach for Vimoire's snippet cards.

---

## Dependency Consolidation

**Current dependencies that snacks could replace:**

| Current | Snacks Equivalent |
|---------|-------------------|
| telescope.nvim | Snacks.picker |
| telescope-file-browser.nvim | Snacks.picker (custom) or vim.ui.select |
| (none) | Snacks.input, Snacks.notifier, Snacks.zen |

**Keep regardless:**
- neo-tree.nvim (manuscript tree view)
- plenary.nvim (utilities, pulled by others anyway)
- treesitter (syntax, required)

**Net effect:** Could remove telescope + telescope-file-browser, add snacks. Roughly equivalent dependency count but more features.

---

## Recommended Adoption Strategy

### Phase 1: UI Primitives ✓
1. Add snacks.nvim dependency
2. Enable `input` - replaces vim.ui.input with floating prompts
3. Enable `picker.ui_select` - replaces vim.ui.select with picker
4. Zero code changes, immediate polish for Add/Delete/Rename flows

### Phase 2: Dashboard Evaluation
1. Prototype start screen in snacks dashboard
2. Compare: is it simpler or fighting the abstraction?
3. Decide: migrate or keep custom dashboard.lua

### Phase 3: Evaluate Picker Migration
1. Prototype one picker (manuscript) in snacks
2. Compare code complexity, UX
3. Decide: migrate all pickers or keep telescope

### Phase 4: Zen Mode (Deferred)
1. Configure zen mode for prose
2. Add `:VimoireZen` toggle command
3. Test with neo-tree - verify no conflicts
4. If works: closes the text centering issue

### Deferred: Other Polish
- `notifier` - pretty notifications (add when we have more user feedback moments)
- `scroll` - smooth scrolling (minor polish)

---

## Configuration Skeleton

```lua
-- In plugin setup (current)
require("snacks").setup({
  -- Phase 1: UI primitives (done)
  input = { enabled = true },
  picker = { ui_select = true },

  -- Phase 2: Dashboard (if adopted)
  dashboard = { enabled = false },

  -- Phase 3: Full picker migration (if migrating from telescope)
  -- picker = { enabled = true },  -- full picker, not just ui_select

  -- Phase 4: Zen mode (deferred)
  zen = { enabled = false },

  -- Deferred polish
  notifier = { enabled = false },
  scroll = { enabled = false },

  -- Skip
  dim = { enabled = false },
  explorer = { enabled = false },
})
```

---

## Open Questions

1. **Zen + Neovide:** Does zen mode work well with Neovide's rendering, or does Neovide have its own approach?

2. **Dashboard recent projects:** Can dashboard show directories (projects) rather than files? Need to test.

3. **Picker preview:** Does snacks picker support the same preview customization (wrap, linebreak) that we configured for telescope?

4. **Image + Neovide:** Neovide has its own image rendering. Does snacks image conflict or complement?
