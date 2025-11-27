# Vimoire — Architecture Overview

### Sections

**manuscript.json**: JSON file per project defines sections, chapters, order, titles, and metadata.
**Book project structure**: A single project uses a specific UUID and domain based file structure.
**Plugin architecture**: Suggested example architecture for the lua plugin we are writing.

---

## manuscript.json

Flat structure: chapters at top level with section references. Sections maintain chapter ordering via `chapter_ids`.

```json
{
  "title": "The Unreliable Memoirs of Gerald the Sentient Toaster",
  "id": "bk2xqr",
  "description": "",
  "chapters": [
    {
      "id": "chap1a",
      "title": "The Day I Became Sentient",
      "section": "sec001"
    },
    {
      "id": "chap1b",
      "title": "Bread: A Love Story",
      "section": "sec001"
    }
  ],
  "sections": [
    {
      "id": "sec001",
      "title": "Part 1",
      "chapter_ids": ["chap1a", "chap1b", "chap1c"]
    },
    {
      "id": "sec002",
      "title": "Part 2",
      "chapter_ids": ["chap2a", "chap2b"]
    }
  ]
}
```

---

## Book Project File Structure

```
book_root/
  manuscript.json

  sections/
    <uuid>/
      title.md

  chapters/
    <uuid>/
      text.md
      notes.md
      comments.json
      snippets.json

  planning/
    characters/
      <name>.md
    settings/
      <name>.md
    research/
      <topic>.md

  notes.md
  assets/
  spell/en.add
  build/
```

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
