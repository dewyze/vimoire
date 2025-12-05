# Vimoire — Architecture Overview

### Sections

**manuscript.json**: JSON file per project defines sections, chapters, order, titles, and metadata.
**Book project structure**: A single project uses a specific UUID and domain based file structure.
**Plugin architecture**: Suggested example architecture for the lua plugin we are writing.

---

## manuscript.json

Nested structure: `items` array contains entries (chapters, pages) and sections. Sections have their own nested `items` array. This makes tree operations (K/J reordering, moving between sections) natural—just array manipulations.

```json
{
  "id": "bk2xqr",
  "title": "The Unreliable Memoirs of Gerald the Sentient Toaster",
  "description": "",
  "items": [
    {
      "id": "sec001",
      "kind": "section",
      "name": "Part 1",
      "items": [
        { "id": "part1tp", "kind": "page", "name": "Part One" },
        { "id": "chap1a", "kind": "chapter", "name": "The Day I Became Sentient" },
        { "id": "chap1b", "kind": "chapter", "name": "Bread: A Love Story" }
      ]
    },
    { "id": "intrlud", "kind": "page", "name": "Interlude" },
    {
      "id": "sec002",
      "kind": "section",
      "name": "Part 2",
      "items": [
        { "id": "chap2a", "kind": "chapter", "name": "Exile in the Drawer" }
      ]
    }
  ],
  "characters": [
    { "id": "char1", "name": "Gerald", "file": "gerald.md" }
  ],
  "settings": [
    { "id": "set1", "name": "The Kitchen", "file": "kitchen.md" }
  ],
  "reference": [
    { "id": "ref1", "name": "Sentience Theory", "file": "sentience.md" },
    {
      "id": "sub1",
      "kind": "subfolder",
      "name": "Bread",
      "items": [
        { "id": "ref2", "name": "Types of Bread", "file": "types.md" }
      ]
    }
  ]
}
```

Note: The manuscript `title` is the book title. Items use `name` for their display label.

**Entry kinds:**
- `chapter` — numbered, has text.md and notes.md
- `page` — unnumbered (title pages, interludes, appendices), has text.md and notes.md
- `section` — container only, no files, just groups entries

**Planning item kinds:**
- Planning items have `id`, `name`, and `file` (relative path)
- `subfolder` — container for nested planning items, has `items` array

---

## Book Project File Structure

```
book_root/
  manuscript.json

  entries/
    <uuid>/              # chapters and pages
      text.md
      notes.md
      comments.json
      snippets.json

  planning/
    characters/
      <name>.md
      <subfolder>/        # optional grouping
        <name>.md
    settings/
      <name>.md
    reference/
      <topic>.md

  notes.md
  assets/
  spell/en.add
  build/
```

Note: Sections exist only in manuscript.json as containers—no files on disk.

---

## Plugin Architecture

The plugin is organized into logical modules:

- **Core**: Manuscript loading, state management, healthcheck
- **Navigation**: Neotree source, Telescope pickers, surface navigation
- **Authoring**: Filetype configuration, panels system, notes/snippets/comments
- **Planning**: Planning doc discovery and management
- **Plotting**: Plot grid and chapter kanban views
- **Spell**: Book-local spellchecking
- **Export**: Manuscript assembly and Pandoc pipeline
- **QoL**: Diagnostics and Neovide-specific enhancements

---

---

## Neotree Navigation Operations

The neotree source provides a hierarchical manuscript view with the following operations:

**Manuscript (root):**
- Add section
- Add chapter (only if default section exists)

**Section:**
- Rename section
- Remove section (with safety checks)
- Move section up/down (reorder)
- Add chapter

**Chapter:**
- Open text.md
- Rename chapter
- Add another chapter in same section
- Remove chapter (prompts user about snippet handling: transfer or delete)
- Move chapter up/down (reorder)

**Planning Folders (Characters, Settings, Reference):**
- Add item (character, setting, or reference)
- Items display alphabetically; fuzzy finder recommended for large lists

**Planning Items (Character, Setting, Reference files):**
- Open file
- Remove file
- Edit frontmatter (name, age/location) directly in editor

---

## Notes

- This is a suggested structure. Adjust as needed.
- Vimoire runs in isolated `NVIM_APPNAME=vimoire` config.
- Plotting can be extracted to separate plugin later.

---

## ID Scheme

Chapters, sections, and other entities use **6-character alphanumeric IDs** (a-z, 0-9) generated randomly with collision detection. At 36^6 combinations (2.1 billion), collisions are statistically impossible for books of any practical size. ID generation includes a collision check against existing IDs in the manuscript.

---

## Bootstrap & App Launch (Future-Proofing)

Currently, vimoire requires the user to open Neovim from the manuscript root directory. **Future app packaging** may want:
- File picker dialog to select a manuscript folder
- Command-line argument for manuscript path
- Remember last opened project

**Design constraint for init.lua:** Build it to accept manuscript path from multiple sources (in order):
1. Command-line argument (passed by app launcher)
2. Environment variable (set by wrapper script)
3. Current working directory (fallback)
4. User prompt (if not found)

This allows the core logic to remain unchanged while supporting different launch modes (CLI, file picker, remembered project) without refactoring later.

---

## User Configuration

**Location:** `~/.config/vimoire/config.lua`

**Loading strategy:**
- App code uses `vimoire.config` module with defaults
- On startup, explicitly loads `~/.config/vimoire/config.lua` (hardcoded path, NOT via stdpath)
- User config merged with defaults using `vim.tbl_deep_extend("force", defaults, user_config)`

**Why hardcoded path:**
- App code location varies (dev symlink, Homebrew install)
- User config location is fixed and expected
- Launcher script can set `XDG_CONFIG_HOME` to point Neovim at app code without affecting user config path

**Example wrapper script for Homebrew:**
```bash
#!/bin/bash
# /opt/homebrew/bin/vimoire
XDG_CONFIG_HOME="/opt/homebrew/opt/vimoire/app/.." \
NVIM_APPNAME=vimoire \
neovide "$@"
```

**Development setup:**
- Symlink: `ln -s /path/to/repo/app ~/.config/vimoire`
- User config lives at `~/.config/vimoire/config.lua` (git-ignored)
- App loads it explicitly from hardcoded path
