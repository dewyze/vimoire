# Vimoire

**Vim + Grimoire.** A magical tome for crafting stories.

<p align="center">
  <img src="assets/icon.png" width="384">
</p>

Vimoire is a standalone Neovim app for writing long-form fiction. Modal editing, manuscript structure, and export to real formats—without the cruft of an IDE or the mouse-dependency of traditional writing software.

<p align="center">
  <img src="assets/dashboard.png">
</p>

## Why?

Because writing a novel in VS Code feels wrong. Because Google Docs makes you reach for the mouse. Because Word is where prose goes to die in a sea of ribbon menus.

Writers who've touched vim know the feeling: your fingers think in motions, not clicks. `ciw` to replace a word. `}` to jump paragraphs. `/dragon` to find every mention of that character you keep forgetting to describe.

Vimoire takes that muscle memory and wraps it in an environment built for stories, not code.

## Features

### Manuscript Structure

<p align="center">
  <img src="assets/navigator_manuscript.png" width="400">
</p>

Organize your book with **chapters**, **pages**, and **sections**:

- **Chapters** — numbered, the spine of your story
- **Pages** — unnumbered content (title pages, interludes, appendices)
- **Sections** — containers that group entries (organizational only—they don't appear in exports)

Reorder with `K`/`J` in the navigator. No drag-and-drop required.

### Planning Documents

Keep your worldbuilding close:

- **Characters** — who's in your story
- **Settings** — where things happen
- **Reference** — research, timelines, plot notes

All searchable via `<leader>fp`.

### Prose-First Editing

<p align="center">
  <img src="assets/prose.png">
  <br><em>Focus mode</em>
</p>

Vimoire remaps navigation for paragraphs, not code:

- `j`/`k` move by **display line**, not buffer line
- `A`/`I` work at display line boundaries
- `)`/`(` navigate sentences
- Focus mode centers your prose and hides the chrome

The `g` prefix escapes to buffer lines when you need them.

### Export

When it's time to share your work:

```
:Export
```

Pandoc-powered export to **EPUB** and **DOCX**. Chapter numbering, scene breaks, and proper formatting—handled.

### Themes

Twelve moods for writing. Switch with `:Theme` or set in config.

|   |   |   |
|:---:|:---:|:---:|
| **Dark** | | |
| ![Inkwell](assets/themes/inkwell.png) | ![Umbra](assets/themes/umbra.png) | ![Abyss](assets/themes/abyss.png) |
| Inkwell · *Warm candlelight* | Umbra · *High contrast* | Abyss · *Ocean blues* |
| ![Hollow](assets/themes/hollow.png) | ![Dusk](assets/themes/dusk.png) | ![Tempest](assets/themes/tempest.png) |
| Hollow · *Forest greens* | Dusk · *Twilight purples* | Tempest · *Storm grays* |
| ![Hearth](assets/themes/hearth.png) | ![Nebula](assets/themes/nebula.png) | ![Frost](assets/themes/frost.png) |
| Hearth · *Firelight reds* | Nebula · *Cosmic purples* | Frost · *Arctic blues* |
| **Light** | | |
| ![Parchment](assets/themes/parchment.png) | ![Vellum](assets/themes/vellum.png) | ![Lumen](assets/themes/lumen.png) |
| Parchment · *Warm cream* | Vellum · *Aged sepia* | Lumen · *High contrast* |

### The Little Things

**Plotting boards** — grid-based planning for plot threads, character arcs, or any tabular structure. Navigate with `hjkl`, edit cells in popups.

**Snippets** — extract text to reuse anywhere.

<p align="center">
  <img src="assets/snippets.png">
</p>

**Marks** — inline annotations that don't export.

<p align="center">
  <img src="assets/marks.png">
</p>

**Comments** — attach notes to any text range for self-editing and review. Select text, `<leader>cc` to annotate, `K` to view, `]c`/`[c` to navigate. Perfect for marking sections that need work, tracking revision notes, or beta reader feedback. Each theme uses a unique sign in the gutter.

**Notes** — per-chapter scratch space, spellcheck-free.

**Book-local dictionary** — teach it your character names once.

**Writing stats** — session word count, book total, chapter breakdown. Set goals in `book.yml` to track progress toward your target.

## Quick Start

1. Launch Vimoire (see [Installation](#installation))
2. From the dashboard, create a new project or open an existing one
3. Use the navigator (`<leader>nt`) to browse your manuscript
4. `a` to add chapters, `K`/`J` to reorder, `<CR>` to open
5. Write. `<leader>fm` to jump between chapters.
6. `:Export` when you're ready to share

Your prose lives in plain markdown files—readable anywhere, forever.

## Installation

```bash
# Clone the repo
git clone https://github.com/dewyze/vimoire ~/dev/vimoire

# Symlink the app directory
ln -s ~/dev/vimoire/app ~/.config/vimoire

# Add bin to your PATH, or symlink the launcher
ln -s ~/dev/vimoire/bin/vimoire /usr/local/bin/vimoire
```

Then run `vimoire` to launch.

By default, Vimoire uses [Neovide](https://neovide.dev) (recommended for the best experience). To use terminal Neovim instead:

```bash
export VIMOIRE_EDITOR=nvim
```

User configuration lives in `~/.vimoire/` (created automatically on first launch).

## Configuration

Customize via `~/.vimoire/config.lua`:

```lua
return {
  colorscheme = "parchment",
  plugins = {
    { "tpope/vim-surround" },
  },
}
```

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for all options.

## Requirements

- Neovim 0.10+
- [Pandoc](https://pandoc.org) (for export)
- [Neovide](https://neovide.dev) (optional, recommended)
- A [Nerd Font](https://www.nerdfonts.com) (for navigator icons)

## Philosophy

- **Writers are professionals.** The tool should stay out of the way.
- **Muscle memory matters.** If you know vim, you know 90% of Vimoire.
- **Plain text is forever.** Your prose lives in markdown files you can read anywhere.
- **Fewer features, done well.** We're not building Scrivener. We're building a grimoire.

## About This Project

Vimoire is almost entirely vibe-coded—built with heavy LLM assistance to scratch a personal itch. This means there are likely bugs, antipatterns, or rough edges I haven't caught. If you spot something off, please open an issue. Feedback genuinely welcome.

## Acknowledgments

Vimoire is built on the shoulders of giants:

- [Neovim](https://neovim.io) — the engine that makes modal prose editing possible
- [Neovide](https://neovide.dev) — the GUI that makes it feel like a native app

## License

MIT

---

*"The first draft is just you telling yourself the story."* — Terry Pratchett

*And the second draft is you telling vim to `:%s/said/muttered/gc`.*
