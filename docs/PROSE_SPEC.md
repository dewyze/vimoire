# Vimoire — Prose Editing Experience Spec

Phase 4 implementation spec. See `ARCHITECTURE.md` for general plugin structure.

---

## Overview

Custom filetypes and display settings that make editing long-form fiction feel like prose, not markup. Markdown is the storage/export format, but the editing experience should be clean and distraction-free.

---

## Filetypes

| Filetype | Use | Spell | Style |
|----------|-----|-------|-------|
| `vimoire_prose` | Chapter/page prose.md | ON | Prose (concealed, centered) |
| `vimoire_markdown` | Notes, planning docs | OFF | Standard markdown |

Both filetypes use the markdown treesitter parser (registered via `vim.treesitter.language.register`), but with different highlight queries and buffer settings.

---

## Prose Mode (`vimoire_prose`)

### Centering

Text displays in a fixed-width column (~86 characters) centered in the window.

**Implementation:** Use `no-neck-pain.nvim` — creates side buffer splits as padding. Chosen over `zen-mode.nvim` because:
- Persistent layout (not a toggle mode)
- Integrates with neotree (tree stays left, padding adjusts)
- Survives buffer switching

**Neotree integration:** When neotree is open, it occupies the left side. The centered prose area shrinks/adjusts. Padding is always present on the right.

**Fallback:** If no-neck-pain proves problematic, `zen-mode.nvim` is the backup option.

**Neovide polish (optional):**
- `vim.opt.linespace = 2` for manuscript-feel line spacing
- `neovide_padding_*` for GUI window margins (doesn't affect text centering, just visual polish)

### Display Settings

```lua
vim.opt_local.wrap = true
vim.opt_local.linebreak = true      -- wrap at word boundaries
vim.opt_local.breakindent = false   -- wrapped lines flush left
vim.opt_local.textwidth = 0         -- no hard wrapping
vim.opt_local.spell = true
vim.opt_local.spelllang = "en"
vim.opt_local.spellfile = "<book_root>/spell/en.add"
```

### Navigation

Remap `j`/`k` to `gj`/`gk` for visual line movement (soft-wrap aware):

```lua
vim.keymap.set('n', 'j', 'gj', { buffer = true })
vim.keymap.set('n', 'k', 'gk', { buffer = true })
```

### Paragraph Behavior

**File format:** Each paragraph on its own line, starting with a literal tab (`\t`). No blank lines between paragraphs in the source file.

```
	This is paragraph one. When the text wraps it
goes back to the margin without indent, just
like a printed book.
	Next paragraph starts indented again.
	"Dialogue works the same way," she said.
	"Each line is a new paragraph," he replied.
```

**Autoindent:** `autoindent` is enabled so Enter preserves the tab indent from the current line. No keymap override needed.

**New files:** Start with a tab character so first paragraph is properly indented.

**Export preprocessing:** Standard markdown requires blank lines between paragraphs. The export pipeline converts single `\n` to `\n\n` before feeding to pandoc, so `<p>` tags are generated correctly. This keeps the editor experience clean (no visible blank lines) while producing valid markdown for pandoc.

### Concealing

Aggressive concealment — hide markdown syntax, show styled text.

| Markdown | Display | Notes |
|----------|---------|-------|
| `_italics_` | *italics* | Underscores hidden, italic highlight |
| `**bold**` | **bold** | Asterisks hidden, bold highlight |
| `***` | § | Scene break rendered as section sign, centered |
| `# Title` | Title | Hash hidden, styled as chapter header |

**Scene break sigil:** Default `§` (section sign). Should be configurable.

**Why `***` not `---`:** Without blank lines between paragraphs, `---` directly after text can be parsed as a setext heading underline. `***` is unambiguous.

**Implementation:** Custom treesitter highlight queries with `conceal` and `@conceal` captures. Set `conceallevel=2` and `concealcursor=nc`.

### Chapter Numbers

Chapters can include a number tag that updates when reordered:

```markdown
# Chapter {{chapter}}: The Day I Became Sentient
```

**Behavior:**
- `{{chapter}}` displays as the chapter's current position number
- Updates automatically when chapters are reordered in neotree
- Export pipeline replaces tag with actual number

**Implementation options:**
- Extmarks with virtual text replacement
- Conceal + virtual text overlay
- Process on save/export only (simpler)

**Deferred decision:** Exact implementation TBD during spike.

### Cursor Line

Subtle highlight — not a bright bar, just enough to track position.

```lua
vim.opt_local.cursorline = true
-- Plus subtle highlight group definition
```

---

## Standard Markdown Mode (`vimoire_markdown`)

More traditional markdown editing for notes and planning documents.

### Display Settings

```lua
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = false         -- no spellcheck
```

### Features

- Headers (`#`, `##`, `###`) render at different sizes/styles
- Links enabled (useful for reference docs)
- Less aggressive concealing (or none)
- Standard Enter behavior (single newline)

### Tab Settings

```lua
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true      -- or false, TBD
```

---

## Spellcheck

**Scope:** Only `vimoire_prose` buffers (chapter/page prose).

**Dictionary:** Book-local at `<book_root>/spell/en.add`.

**Setup:**
```lua
vim.opt_local.spell = true
vim.opt_local.spelllang = "en"
vim.opt_local.spellfile = vim.fn.expand(book_root .. "/spell/en.add")
```

**Directory creation:** `spell/` directory created on first `zg` (add word) if it doesn't exist.

---

## Filetype Detection

Set filetype based on buffer type when opened via neotree/telescope:

Set filetype when opening: `vimoire_prose` for chapter/page prose.md, `vimoire_markdown` for notes and planning docs.

Buffer metadata (`vim.b.vimoire_item_id`) set on open for plugin commands.

---

## Treesitter Integration

Register markdown parser for all custom filetypes:

```lua
vim.treesitter.language.register('markdown', 'vimoire_prose')
vim.treesitter.language.register('markdown', 'vimoire_markdown')
```

Custom highlight queries in:
- `queries/vimoire_prose/highlights.scm` — prose concealing
- `queries/vimoire_markdown/highlights.scm` — standard markdown (or inherit)

---

## Deferred / Out of Scope

**Dialogue highlighting:** Quoted text gets subtle highlight. Treesitter may not parse this natively — needs spike. Many edge cases (nested quotes, apostrophes, etc.). Implement later.

**Chapter number export processing:** `{{chapter}}` tag replacement in export pipeline. Implement with export phase.

**Header navigation in notes:** Treesitter-based outline/navigation for headers in notes.md. Nice to have, not Phase 4.

**Images:** `![alt](path)` syntax. Leave as-is for now (not concealed, not rendered). Revisit if needed.

---

## Implementation Order

1. **Custom filetypes** — register filetypes, treesitter parser
2. **Prose settings** — wrap, linebreak, breakindent, j/k remaps
3. **Paragraph behavior** — autoindent, new file template
4. **Concealing** — highlight queries for italics, bold, scene breaks
5. **Scene break sigil** — centered `§` rendering
6. **Spellcheck** — enable for vimoire_prose, book-local dictionary
7. **Notes/planning settings** — standard markdown behavior
8. **Centering** — DEFERRED (see Research Notes)

---

## Dependencies

**Already present:**
- `nvim-treesitter` — syntax parsing
- `plenary.nvim` — utilities

**Deferred:**
- `no-neck-pain.nvim` — text centering (installed but not integrated, see Research Notes)

---

## Configuration (User)

Configurable options (via `~/.config/vimoire/config.lua`):

```lua
{
  prose = {
    width = 86,                    -- centered column width
    scene_break_sigil = "§",       -- scene break display character
    line_numbers = false,          -- show line numbers in prose
    cursorline = true,             -- subtle cursor line highlight
  },
  spell = {
    enabled = true,                -- spellcheck in prose
    lang = "en",
  },
}
```

---

## Research Notes

### Centering Approaches Evaluated

| Approach | Verdict | Notes |
|----------|---------|-------|
| `no-neck-pain.nvim` | ⏸️ Deferred | Model mismatch with neotree (see below) |
| `zen-mode.nvim` | Backup | Floating window, feels like a "mode" |
| Neovide padding | Polish only | Pads window, doesn't constrain text |
| Extmarks/virtual text | ❌ | Breaks soft-wrap |
| statuscolumn | ❌ | Performance issues, breaks soft-wrap |

### no-neck-pain.nvim Spike (2024-12)

**Problem:** no-neck-pain pads the entire vim frame, not individual windows. With neotree on left, it creates: `[left-pad] [neotree] [text]` instead of desired `[neotree] [left-pad] [text] [right-pad]`.

**Root cause:** The plugin's model is "center everything in vim" not "center this specific window." The NeoTree integration only tells it to subtract neotree's width from calculations, not to place padding *around* the editing area.

**Options to revisit:**
1. Right-only padding (`left.enabled = false`) — neotree acts as left margin
2. zen-mode.nvim — different model, may handle sidebars better
3. Custom solution — manual scratch buffer splits with precise positioning
4. Investigate order of operations — enable no-neck-pain before neotree opens

**Decision:** Defer centering. Rest of prose experience (filetypes, concealing, paragraph behavior, spellcheck) is independent.

### Variable-Width Fonts

Not supported. Neovim/Neovide are grid-based — every cell same width. All positioning assumes monospace. Neovide font config is for choosing which monospace font, not enabling proportional text.

### Blank Line Minimization

Investigated options for reducing visual height of blank lines. No clean solution found. Accept as-is — the blank line is structurally required for markdown, visual spacing is acceptable.
