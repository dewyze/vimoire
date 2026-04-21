# Vimoire — Architecture

Internal reference for understanding how Vimoire structures data.

---

## book.yml

User-facing identity file. Editable by the user.

```yaml
title: "The Unreliable Memoirs of Gerald the Sentient Toaster"
description: "A toaster gains sentience and has feelings about bread."
author: "Author Name"
language: en
cover: "assets/images/cover.jpg"  # optional
goals:                            # optional
  target_words: 80000             # total book word count goal
  daily_words: 1000               # daily writing goal
```

---

## manuscript.json

Internal structural state. Not user-edited—modified via app operations.

Nested `items` array contains entries (chapters, pages) and sections. Sections have their own nested `items` array. This makes tree operations (K/J reordering, moving between sections) natural—just array manipulations.

```json
{
  "id": "bk2xqr",
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
    { "id": "chr001", "name": "Gerald" }
  ],
  "settings": [
    { "id": "set001", "name": "The Kitchen" }
  ],
  "reference": [
    { "id": "ref001", "name": "Sentience Theory" },
    {
      "id": "sub001",
      "kind": "subfolder",
      "name": "Bread",
      "items": [
        { "id": "ref002", "name": "Types of Bread" }
      ]
    }
  ]
}
```

**Entry kinds:**
- `chapter` — numbered, has prose.md and notes.md
- `page` — unnumbered (title pages, interludes, appendices), has prose.md and notes.md
- `section` — container only, no files, just groups entries

**Planning items:**
- Have `id` and `name`, stored as `planning/<id>/text.md`
- `subfolder` — container for nested items (reference only), has `items` array

---

## File Structure

```
book_root/
  book.yml                    # user-facing book identity
  manuscript.json             # internal structural state

  entries/
    <id>/                     # chapters and pages
      prose.md
      notes.md

  planning/
    <id>/                     # characters, settings, reference, orphaned_notes
      text.md

  snippets/
    <id>.md                   # extracted text snippets

  assets/
    images/                   # book images, cover

  exports/
    templates/                # pandoc templates (epub.css, etc.)
    configs/                  # export configuration YAML
    output/                   # generated EPUB/DOCX

  spell/
    en.add                    # book-local dictionary
```

Note: Sections exist only in manuscript.json as containers—no files on disk.

---

## ID Scheme

All entities use **6-character alphanumeric IDs** (a-z, 0-9) generated randomly with collision detection. At 36^6 combinations (2.1 billion), collisions are statistically impossible for books of any practical size.

---

## Buffer Metadata

When files are opened via navigator or pickers, the buffer is tagged with `vim.b.vimoire_item_id`. This enables buffer-context commands like `:OpenNotes` to know which chapter/page the user is editing.

**Shared open logic:** `vimoire.navigation.open` provides `open_item(item)` which:
1. Opens the file with `:edit`
2. Sets `vim.b.vimoire_item_id`

Both navigator and pickers use this to ensure consistent behavior.

---

## Bootstrap

Vimoire accepts manuscript path from multiple sources (in order):
1. Command-line argument (passed by app launcher)
2. Environment variable (set by wrapper script)
3. Current working directory (fallback)
4. Dashboard prompt (if not found)

This allows the core logic to support different launch modes (CLI, app bundle, remembered project) without refactoring.

---

## User Configuration

**Location:** `~/.vimoire/config.lua`

Separate from `~/.config/vimoire/` (app code via `NVIM_APPNAME`). This means:
- App code location varies (dev symlink, Homebrew install, etc.)
- User config is always `~/.vimoire/` regardless of install method

See [CONFIGURATION.md](CONFIGURATION.md) for all options.
