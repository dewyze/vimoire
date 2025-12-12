# Vimoire — Prose Editing Experience Spec

Phase 4 implementation spec. See `ARCHITECTURE.md` for general plugin structure.

---

## Overview

Custom filetypes and display settings that make editing long-form fiction feel like prose, not markup. Markdown is the storage/export format, but the editing experience should be clean and distraction-free.

---

## Filetypes

| Filetype | Use | Spell | Style |
|----------|-----|-------|-------|
| `vimoire_prose` | Chapter/page prose.md | ON | Prose (styled, visible syntax) |
| `vimoire_markdown` | Notes, planning docs | OFF | Standard markdown |

`vimoire_prose` uses a custom vim syntax file (not treesitter) because standard markdown treats tab-indented lines as code blocks. `vimoire_markdown` uses the treesitter markdown parser.

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

### Syntax Styling

Markdown syntax remains visible; styled text gets formatting applied. No concealing (hide/reveal as cursor moves was deemed more distracting than helpful).

| Markdown | Display | Notes |
|----------|---------|-------|
| `*text*` | `*text*` (italic) | Asterisks visible, content styled italic |
| `**text**` | `**text**` (bold) | Asterisks visible, content styled bold |
| `***text***` | `***text***` (bold+italic) | Both styles applied |
| `_text_` | `_text_` (underline) | Underscores visible, content underlined |
| `***` | `***` (styled) | Scene break, distinct highlight |
| `# Title` | `# Title` (styled) | Hash visible, header styling applied |
| `##` through `######` | Styled | All 6 header levels supported |
| `::: name` | `::: name` (dimmed) | Fenced div markers, subtle styling |

**Why `***` not `---` for scene breaks:** Without blank lines between paragraphs, `---` directly after text can be parsed as a setext heading underline. `***` is unambiguous.

**Implementation:** Custom vim syntax file. See "Syntax Highlighting Strategy" section for details.

### Vimoire Metadata Tags (`{{...}}`)

The `{{...}}` syntax is reserved for metadata that requires vimoire context. Pandoc doesn't understand these — vimoire's preprocessor handles them before export.

| Tag | Purpose | Export behavior |
|-----|---------|-----------------|
| `{{chapter}}` | Chapter position number | Replaced with number |
| `{{mark}}` | Navigation point | Stripped |
| `{{todo}}` | Action item | Stripped |
| `{{todo:description}}` | Action item with text | Stripped |

**Chapter numbers:**

```markdown
# Chapter {{chapter}}: The Day I Became Sentient
```

- Displays current chapter position
- Updates when chapters reordered in neotree
- Export replaces with actual number

**Marks:**

```markdown
	The hero arrived at the castle gates.
{{mark}}
	"Who goes there?" called the guard.
```

- Navigation points for jumping within/between chapters
- Visible in editor, stripped on export
- Future: telescope picker for marks, named marks (`{{mark:name}}`)

**Todos:**

```markdown
	She reached into her pocket and pulled out {{todo:what does she pull out?}}
{{todo}}
	The next scene needs work.
```

- Action items visible in editor
- Future: todo navigator/panel to list all todos across manuscript
- Stripped on export

**In-editor display:** Metadata tags get distinct styling (dimmed or highlighted) to stand out from prose without being distracting.

### Styled Blocks (Pandoc Fenced Divs)

For prose that needs distinct visual treatment (letters, telegrams, journal entries, epigraphs), use pandoc's native fenced div syntax:

```markdown
::: letter
Dear Sir,

I write to inform you that your application has been denied.

Yours truly,
The Committee
:::
```

**Why fenced divs:**
- Pandoc handles them natively — no preprocessing needed for structure
- Visually distinct from inline `{{...}}` replacements
- Clear block semantics (opening and closing fences)
- Works across all pandoc output formats

**Output by format:**

| Format | Result |
|--------|--------|
| HTML | `<div class="letter">...</div>` |
| DOCX | Paragraphs with "Letter" style applied |
| PDF | LaTeX `\begin{letter}...\end{letter}` environment |

**Styling configuration:**
- HTML: CSS targets `.letter`, `.telegram`, etc.
- DOCX: Define styles in a reference template document
- PDF: Define LaTeX environments in custom template

**Common block types:**
- `letter` — correspondence embedded in narrative
- `telegram` — terse period communications
- `journal` — diary entries, personal logs
- `epigraph` — chapter-opening quotes
- `newspaper` — clippings, articles

**In-editor display:** Vim syntax can match fenced divs and apply subtle styling (dimmed fences, distinct background). Content inside still gets normal prose highlighting.

**Syntax distinction:**

| Syntax | Type | Handled by |
|--------|------|------------|
| `{{chapter}}` | Inline replacement | Vimoire preprocessor |
| `::: letter` | Block wrapper | Pandoc native |

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
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
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

## Syntax Highlighting Strategy

### The Core Problem

**Standard markdown interprets tab-indented lines as code blocks.**

Vimoire prose uses tab indentation for paragraphs (essential for distinguishing dialogue from narration at a glance). This conflicts with markdown's design:

- Treesitter's markdown parser sees tabs → marks as `indented_code_block`
- Code blocks get syntax highlighting (typically blue/different color)
- Concealing may not work inside code block nodes
- Text objects and motions may misbehave

We still need markdown's inline formatting: `*italics*`, `**bold**`, block quotes, and `***` scene breaks. But we don't need code blocks, links, images, lists, or tables.

### Options Evaluated

| Approach | Effort | Verdict | Notes |
|----------|--------|---------|-------|
| **Pure Vim Syntax** | Low | ✅ Chosen | Full control, no parser fighting us |
| Custom Treesitter Grammar | High | ❌ Overkill | Fork markdown grammar, remove code block rule. Correct but maintenance burden. |
| Override Highlights | Low | ❌ Risky | Parser still thinks tabs=code. Concealing, text objects may break. |
| Accept Standard Markdown | None | ❌ Rejected | Violates core requirement (visible tab indents) |

### Chosen Solution: Vim Syntax

Use a custom vim syntax file (`syntax/vimoire_prose.vim`). No treesitter parser—tabs are just tabs.

**What to highlight:**
- Inline formatting: `*italic*`, `**bold**`, `_underline_`, `***bold italic***`
- Headers: `#` through `######` (all 6 levels)
- Block quotes: `>` lines
- Scene breaks: `***` on its own line
- Fenced divs: `::: name` opening/closing markers
- Metadata tags: `{{chapter}}`, `{{mark}}`, `{{todo}}`, `{{todo:text}}`

No concealing — all syntax remains visible, only styling applied.

### Edge Cases

| Case | Handling |
|------|----------|
| Nested `***bold italic***` | Matched before `**` and `*` (order matters in syntax file) |
| Multi-line block quotes | `syn region` handles continuation; or use line-by-line matching |
| Fenced divs `::: letter` | Fence lines highlighted as Comment, content inside gets normal prose highlighting |
| Apostrophes in contractions | `_` underline requires non-`_` after opening, avoids `don_t` false match |
| `{{todo:text with spaces}}` | Regex matches everything up to `}}` |

### vimoire_markdown Filetype

For notes.md and planning docs, standard markdown highlighting is fine. These files don't use our tab-indent convention.

**Options:**
1. Use treesitter markdown parser (standard behavior)
2. Use built-in vim markdown syntax
3. Use `vimoire_prose` syntax (consistent concealing)

**Recommendation:** Treesitter markdown for notes/planning. Only prose needs the custom syntax.

```lua
vim.treesitter.language.register('markdown', 'vimoire_markdown')
```

---

## Export Preprocessing

Vimoire's export pipeline preprocesses prose before pandoc processes it:

| Task | Handled by | Notes |
|------|------------|-------|
| `\n` → `\n\n` | Vimoire | Our single-newline paragraphs need blank lines for pandoc |
| `{{chapter}}` | Vimoire | Replaced with chapter position number |
| `{{mark}}` | Vimoire | Stripped (navigation only, not in output) |
| `{{todo}}`, `{{todo:text}}` | Vimoire | Stripped (author notes, not in output) |
| `::: letter` divs | Pandoc | Native support, no preprocessing needed |
| `*italic*`, `**bold**` | Pandoc | Native markdown, no preprocessing needed |

**Export templates:** Format-specific styling configured via:
- `templates/style.css` — HTML/ebook styling
- `templates/reference.docx` — Word style definitions
- `templates/template.tex` — LaTeX environment definitions

---

## Deferred / Out of Scope

**Named marks:** `{{mark:name}}` for labeled navigation points. Basic `{{mark}}` first, named variant later.

**Mark navigator:** Telescope picker to jump between marks across manuscript.

**Todo navigator:** Panel or picker showing all `{{todo}}` items across manuscript.

**`{{chapter}}` live display:** Show chapter number in editor (extmarks/virtual text). For now, just export replacement.

**`{{date:Day 3}}`:** Timeline/chronology tracking within narrative. Cool idea, revisit later.

**`{{ref:name}}`:** Links to planning docs (characters, settings). Revisit if needed.

**Dialogue highlighting:** Quoted text gets subtle highlight. Many edge cases (nested quotes, apostrophes). Implement later.

**Header navigation in notes:** Treesitter-based outline/navigation for headers in notes.md.

**Images:** `![alt](path)` syntax. Leave as-is for now.

**Inline styled spans:** Mid-sentence styling like `<span class="emphasis">word</span>`. Fenced divs are block-level only.

---

## Configuration (User)

Configurable options (via `~/.config/vimoire/config.lua`):

```lua
{
  prose = {
    width = 86,                    -- centered column width (when centering implemented)
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

**Decision:** Defer centering. Rest of prose experience (filetypes, syntax styling, paragraph behavior, spellcheck) is independent.

### Variable-Width Fonts

Not supported. Neovim/Neovide are grid-based — every cell same width. All positioning assumes monospace. Neovide font config is for choosing which monospace font, not enabling proportional text.

### Blank Line Minimization

Investigated options for reducing visual height of blank lines. No clean solution found. Accept as-is — the blank line is structurally required for markdown, visual spacing is acceptable.
