# Vimoire — Summary

A Neovim/Neovide writing environment for long-form fiction.

See `ARCHITECTURE.md` for book.yml structure, project filesystem layout, and plugin module architecture.

## Core Concept

**Filesystem** stores content (markdown, JSON). **book.yml** indexes structure and metadata. Healthcheck detects inconsistencies.

## Features

**Structure & Navigation** — Neotree shows chapters/sections by order; Telescope for fast jump; create/rename/delete/reorder chapters (atomic YAML+FS updates).

**Authoring** — Custom filetype `vimoire.markdown` with role-based settings. Panels for notes, snippets, comments tied to each chapter.

**Notes & Snippets** — Chapter `notes.md` (spellcheck off), and text snippet cards in `snippets.json` (extractable from selection).

**Planning** — Reference docs in `planning/characters|settings|research/`. Can pin any planning doc as a side panel.

**Plotting** — JSON-backed grid (chapters × plotlines) and chapter-level kanban. UI-only editing, syncs to JSON.

**Comments** — Stored in `comments.json` with extmark anchors. Panel view, create/edit/resolve/delete. Not exported by default.

**Spellcheck** — Book-local dictionary (`spell/en.add`). Spellcheck only in chapter prose.

**Export** — Pandoc-based (HTML/EPUB/PDF/DOCX). Assembles ordered chapters into manuscript. Outputs to `build/`.

**Neovide Polish** — Optional variable-width fonts, line spacing, smooth animations for a manuscript feel on Neovide.

## Building Order

1. Core (directory structure, book.yml parsing, healthcheck)
2. Navigation (Neotree, Telescope, file ops)
3. Authoring (filetype, panels)
4. Planning & plotting
5. Spellcheck & export
6. Neovide polish
