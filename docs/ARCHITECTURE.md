# Vimoire — Architecture Overview

### Sections

**manuscript.json**: JSON file per project defines sections, chapters, order, titles, and metadata.
**Book project structure**: A single project uses a specific UUID and domain based file structure.
**Plugin architecture**: Suggested example architecture for the lua plugin we are writing.

---

## manuscript.json

```json
{
  "title": "My Book Title",
  "id": "book-uuid",
  "description": "",
  "created_at": "2025-01-01",
  "updated_at": "2025-01-01",
  "sections": [
    {
      "id": "sec-1111",
      "title": "Part One",
      "status": null,
      "meta": {},
      "chapters": [
        {
          "id": "chap-aaaa",
          "title": "Chapter One",
          "status": null,
          "meta": {}
        },
        {
          "id": "chap-bbbb",
          "title": "Chapter Two",
          "status": null,
          "meta": {}
        }
      ]
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

lua/vimoire/
  init.lua                 # bootstrap
  config.lua               # config defaults
  commands.lua             # :Vimoire... commands
  state.lua                # runtime state

  util/
    log.lua                # logging (vim.notify wrapper)

  core/
    manuscript.lua         # load/manage manuscript.json; Manuscript, Section, Chapter objects
    fs_layout.lua          # filesystem structure rules
    healthcheck.lua        # detect issues, offer repairs
    roles.lua              # map paths to roles

  navigation/
    neotree_source.lua     # custom Neotree source
    telescope_sources.lua  # pickers
    jump.lua               # open surfaces by chapter

  authoring/
    filetype.lua           # vimoire.markdown filetype
    panels.lua             # panel helpers
    notes.lua              # notes panel
    snippets.lua           # snippets.json
    comments.lua           # comments.json

  planning/
    index.lua              # discover planning docs
    panel.lua              # pin as panels

  plotting/
    model.lua              # JSON data
    grid_view.lua          # book grid
    kanban_view.lua        # chapter kanban
    actions.lua            # UI interactions

  spell/
    spellfile.lua          # book-local dictionary
    roles_spell.lua        # conditional spell

  export/
    manuscript.lua         # assemble chapters
    pandoc.lua             # export pipeline

  qol/
    diagnostics.lua        # error messages
    neovide.lua            # Neovide polish

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
