# Vimoire

A Neovim-powered writing environment for long-form fiction.

*Vim + Grimoire: Your magical tome for crafting stories.*

<!-- TODO: Add logo here -->

## What Is This?

Vimoire turns Neovim (or Neovide) into a dedicated novel writing app. It's not a plugin you add to your dev setup, it's a standalone environment with its own config, designed for authors who want the power of modal editing without the cruft of an IDE.

## Getting Started

Vimoire runs in an isolated Neovim config:

```bash
NVIM_APPNAME=vimoire nvim /path/to/your/manuscript
# or with Neovide for that polished manuscript feel
NVIM_APPNAME=vimoire neovide /path/to/your/manuscript
```

## Current Features

### Manuscript Structure
Organize your book with **chapters**, **pages**, and **sections**:
- **Chapters** — numbered, the meat of your story
- **Pages** — unnumbered content (title pages, interludes, appendices)
- **Sections** — containers that group entries (Part 1, Part 2, etc.)

Everything lives in `manuscript.json` with your prose in markdown files.

### Navigation
- **Neo-tree** — visual tree of your manuscript structure, reorder with K/J
- **Telescope** — fuzzy-find any chapter, character, or setting instantly

### Planning
Reference docs organized by purpose:
- `characters/` — who's in your story
- `settings/` — where things happen
- `reference/` — research, worldbuilding, whatever you need

### Keymaps
Modal editing optimized for prose, not code. (Documentation coming.)

## Planned Features

- **Rich Export** — Pandoc pipeline to EPUB, PDF, DOCX
- **Card-Based Plotting** — visual plot grid and chapter kanban
- **Comments & Snippets** — inline annotations and extractable text cards
- **Book-Local Spellcheck** — custom dictionary per manuscript

## License

MIT
