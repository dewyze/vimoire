# Vimoire

**Vim + Grimoire.** A magical tome for crafting stories.

<p align="center">
  <img src="assets/icon.png">
</p>

Vimoire is a Neovim-powered writing environment for long-form fiction. It's not a plugin you bolt onto your dev setup—it's a standalone app with its own config, themes, and keybindings, all designed for authors who want modal editing without the cruft of an IDE.

Think of it as Scrivener for people who think Scrivener has too many buttons and not enough `:wq`.

<p align="center">
  <img src="assets/dashboard.png">
</p>

## Why?

Because writing a novel in VS Code feels wrong. Because Google Docs makes you reach for the mouse. Because Word is where prose goes to die in a sea of ribbon menus.

Writers who've touched vim know the feeling: your fingers think in motions, not clicks. `ciw` to replace a word. `}` to jump paragraphs. `/dragon` to find every mention of that character you keep forgetting to describe.

Vimoire takes that muscle memory and wraps it in an environment built for stories, not code.

## Features

### Your Manuscript, Organized

<p align="center">
  <img src="assets/navigator-manuscript.png">
</p>

Structure your book with **chapters**, **pages**, and **sections**:

- **Chapters** — numbered, the spine of your story
- **Pages** — unnumbered content (title pages, interludes, appendices, that cryptic epigraph you're definitely keeping)
- **Sections** — containers that group entries ("Part One: In Which Nothing Goes According to Plan")

Reorder with `K/J` in the navigator. No drag-and-drop, no mouse required.

### Planning Documents

Keep your worldbuilding close:

- **Characters** — who's in your story (and their shoe size, if that's important to you)
- **Settings** — where things happen
- **Reference** — research, timelines, that Wikipedia rabbit hole you fell into at 2am

All searchable, all a keystroke away with `<leader>fp`.

### Prose-First Editing

<p align="center">
  <img src="assets/prose.png">
</p>

Vimoire knows you're writing paragraphs, not code. In prose buffers:

- `j/k` move by **display line**, not buffer line (because your paragraph shouldn't feel like a canyon)
- `A/I` append and insert at display line boundaries
- `)/(` navigate sentences properly (single-spaced, like a civilized person)
- Visual line navigation everywhere, `g`-prefix escapes to buffer lines when you need them

### Export to Real Formats

When it's time to share your work with people who don't understand why you're excited about macros:

```
:VimoireExport
```

Pandoc-powered export to **EPUB** and **DOCX**. Chapter numbering, scene breaks, and proper formatting—handled.

### Five Moods for Writing

- **Inkwell** — warm dark theme, like writing by candlelight
- **Parchment** — warm light theme, morning coffee and manuscript pages
- **Vellum** — sepia tones, for that "ancient tome" aesthetic
- **Umbra** — high contrast dark, for the minimalist in your soul
- **Lumen** — high contrast light, aggressive clarity

Switch with `:VimoireTheme` or set your preference in config.

### The Little Things

- **Snippets** — extract text to reuse anywhere (`<leader>sx` in visual mode)
- **Marks** — inline annotations that don't export (`{{mark:fix this later}}`)
- **Notes** — per-chapter scratch space, spellcheck-free
- **Book-local dictionary** — teach it your character names, once
- **Focus mode** — margins that center your prose and hide the noise

## Getting Started

Vimoire runs in an isolated Neovim config via `NVIM_APPNAME`:

```bash
# Terminal
NVIM_APPNAME=vimoire nvim

# Or with Neovide for that polished manuscript feel
NVIM_APPNAME=vimoire neovide
```

On first launch, you'll see the dashboard. Create a new project or open an existing one.

### Project Structure

```
my-novel/
  book.yml              # title, author, description
  manuscript.json       # internal structure (don't edit by hand)
  entries/              # your chapters and pages
  planning/             # characters, settings, reference
  exports/              # generated EPUB/DOCX files
  spell/en.add          # your book's dictionary
```

### Configuration

Customize via `~/.vimoire/config.lua`:

```lua
return {
  colorscheme = "vimoire-parchment",
  keymaps = {
    finder = {
      smart = "<C-p>",  -- muscle memory from other editors? we got you
    },
  },
  editor = {
    textwidth = 72,     -- Hemingway would approve
  },
}
```

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for all options.

## Keymaps

Everything uses `<leader>` with mnemonic prefixes:

| Prefix | Domain | Examples |
|--------|--------|----------|
| `<leader>f` | **Find** | `ff` everything, `fm` manuscript, `fp` planning |
| `<leader>n` | **Navigator** | `nt` toggle, `nf` reveal file, `nm` manuscript view |
| `<leader>v` | **View** | `vh` home, `vf` focus mode |
| `<leader>w` | **Writing** | `wn` notes, `wm` marks, `wk` toggle kind |
| `<leader>i` | **Insert** | `im` mark, `ii` image |
| `<leader>s` | **Snippets** | `si` insert, `sx` extract |

Plus `<Esc><Esc>` to clear search highlight, because you'll be searching a lot.

## Requirements

- Neovim 0.10+
- [Neovide](https://neovide.dev) (optional, but recommended for the full experience)
- [Pandoc](https://pandoc.org) (for export)

## Installation

```bash
# Clone to your Neovim configs
git clone https://github.com/yourusername/vimoire ~/.config/vimoire

# Create your user config directory
mkdir -p ~/.vimoire

# Launch
NVIM_APPNAME=vimoire nvim
```

For convenience, add an alias:

```bash
alias vimoire='NVIM_APPNAME=vimoire nvim'
# or
alias vimoire='NVIM_APPNAME=vimoire neovide'
```

## Status

Vimoire is in active development. The core writing experience is solid—manuscript structure, navigation, export, themes. We're working toward a proper macOS app bundle and Homebrew installation.

See [docs/mvp/MVP.md](docs/mvp/MVP.md) for the roadmap.

## Philosophy

- **Writers are professionals.** The tool should stay out of the way.
- **Muscle memory matters.** If you know vim, you know 90% of Vimoire.
- **Plain text is forever.** Your prose lives in markdown files you can read anywhere.
- **Fewer features, done well.** We're not building Scrivener. We're building a grimoire.

## License

MIT

---

*"The first draft is just you telling yourself the story."* — Terry Pratchett

*And the second draft is you telling vim to `:%s/said/muttered/gc`.*
