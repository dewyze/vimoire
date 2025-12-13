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
- `chapter` — numbered, has prose.md and notes.md
- `page` — unnumbered (title pages, interludes, appendices), has prose.md and notes.md
- `section` — container only, no files, just groups entries

**Planning item kinds:**
- Planning items have `id`, `name`, and `file` (relative path)
- `subfolder` — container for nested planning items, has `items` array

**Extras (notes, snippets, comments):**
- Documents have an `extras` flag controlling access to notes.md, snippets.json, and comments.json
- Entries (chapters, pages) have `extras = true` — they get extras
- Planning items have `extras = false` — just the main file

**Document path methods:**
- `dir_path()` — base directory for the document (`<root>/<base>/<id>`)
- `text_path()` — main content file (entries: `prose.md`, planning: `text.md`)
- `notes_path()` — notes file, nil if extras disabled (`dir_path()/notes.md`)

---

## Book Project File Structure

```
book_root/
  manuscript.json

  entries/
    <uuid>/              # chapters and pages
      prose.md
      notes.md
      comments.json
      snippets.json

  planning/
    <uuid>/              # planning items (characters, settings, reference)
      text.md

  notes.md
  assets/
  spell/en.add
  build/
```

Note: Sections exist only in manuscript.json as containers—no files on disk.

---

## Neotree Navigation Operations

The neotree source provides a hierarchical manuscript view with the following operations:

**Manuscript (root):**
- Add section, chapter, or page

**Section:**
- Rename section
- Remove section (with safety checks)
- Move section up/down (reorder)
- Add chapter or page

**Chapter/Page:**
- Open prose.md
- Rename
- Add sibling (chapter or page in same parent)
- Remove (prompts user about snippet handling: transfer or delete)
- Move up/down (reorder)

**Planning Folders (Characters, Settings, Reference):**
- Add item (character, setting, or reference)
- Items display alphabetically; fuzzy finder recommended for large lists

**Planning Items (Character, Setting, Reference files):**
- Open file
- Add sibling item
- Remove file
- Edit frontmatter (name, age/location) directly in editor

---

## Notes

- This is a suggested structure. Adjust as needed.
- Vimoire runs in isolated `NVIM_APPNAME=vimoire` config.
- Plotting can be extracted to separate plugin later.
- **Files should be opened via plugin commands** (neotree, telescope), not directly with `:e`. This allows buffer metadata to be set on open.

---

## Buffer Metadata

When files are opened via neotree or telescope, the buffer is tagged with `vim.b.vimoire_item_id` containing the item's ID. This enables buffer-context commands like `:VimoireNotes` to know which chapter/page the user is editing.

**Shared open logic:** `vimoire.navigation.open` provides `open_item(item)` which:
1. Opens the file with `:edit`
2. Sets `vim.b.vimoire_item_id`

Both neotree and telescope use this to ensure consistent behavior.

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

**Location:** `~/.vimoire/config.lua`

This is intentionally separate from `~/.config/vimoire/` (where app code lives via `NVIM_APPNAME`). This separation means:
- App code location varies (dev symlink, Homebrew install, etc.)
- User config location is always `~/.vimoire/` regardless of install method
- No conflicts between app code and user files

**Loading strategy:**
- App code uses `vimoire.config` module with defaults
- On startup, explicitly loads `~/.vimoire/config.lua` (hardcoded path)
- User config merged with defaults using `vim.tbl_deep_extend("force", defaults, user_config)`

**Example user config:**
```lua
return {
  colorscheme = "vimoire-light",
  keymaps = {
    finder = {
      navigate = "<leader>ff",
    },
  },
}
```

**Development setup:**
- Symlink: `ln -s /path/to/repo/app ~/.config/vimoire`
- User config at `~/.vimoire/config.lua` (create manually if needed)

---

## Colorschemes

Vimoire uses Neovim's native colorscheme system.

**Shipped colorschemes** (in `app/colors/`):
- `vimoire-inkwell` — warm dark theme (default)
- `vimoire-parchment` — warm light theme
- `vimoire-vellum` — sepia/manuscript theme
- `vimoire-umbra` — high contrast monochrome dark theme
- `vimoire-lumen` — high contrast monochrome light theme

**User override:** Set `colorscheme` in `~/.vimoire/config.lua` or use `:colorscheme` at runtime.

**Custom highlight groups:**

Prose syntax (defined in `syntax/vimoire_prose.vim` with `highlight default`):
- `vimoireH1` through `vimoireH6`, `vimoireSceneBreak`, `vimoireBlockQuote`, `vimoireFencedDiv`
- `vimoireMetaChapter`, `vimoireMetaMark`, `vimoireMetaTodo`, `vimoireMetaTodoText`
- `vimoireBoldStyle`, `vimoireItalicStyle`, `vimoireUnderlineStyle`, `vimoireBoldItalicStyle`

UI groups (fallbacks in `lua/vimoire/highlights.lua` via ColorScheme autocmd):
- Navigator: `VimoireManuscript`, `VimoireSection`, `VimoireChapter`, `VimoirePage`, `VimoirePlanning`, `VimoirePlanningSubfolder`, `VimoirePlanningItem`
- Start screen: `VimoireLogo`, `VimoireTagline`, `VimoireStar`, `VimoireHeader`, `VimoireProject`, `VimoireProjectSelected`, `VimoirePath`, `VimoireDate`, `VimoireAction`, `VimoireKey`

**Third-party colorschemes:** Work automatically via fallback links to standard groups (Title, Comment, Function, etc.). Vimoire colorschemes override with specific colors.
