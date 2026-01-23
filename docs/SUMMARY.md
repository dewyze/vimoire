# Vimoire — Summary

A Neovim/Neovide writing environment for long-form fiction.

See `ARCHITECTURE.md` for file structures, project layout, and plugin module architecture.

## Core Concept

**Filesystem** stores content (markdown, JSON). **book.yml** holds user-facing identity (title, author). **manuscript.json** holds internal structure (ordering, IDs). Healthcheck detects inconsistencies.

## Features

**Structure & Navigation** — Neotree shows chapters/sections by order; pickers for fast jump; create/rename/delete/reorder chapters (atomic JSON+FS updates).

**Authoring** — Custom filetype `vimoire.markdown` with role-based settings. Panels for notes, snippets, comments tied to each chapter.

**Notes & Snippets** — Chapter `notes.md` (spellcheck off), and global `snippets.json` for extracted text (cut from selection, insert anywhere). Deleting a chapter preserves its notes in `planning/orphaned_notes/`.

**Planning** — Reference docs in `planning/characters|settings|reference|orphaned_notes/`. Can pin any planning doc as a side panel.

**Plotting** — JSON-backed grid (chapters × plotlines) and chapter-level kanban. UI-only editing, syncs to JSON.

**Comments** — Stored in `comments.json` with extmark anchors. Panel view, create/edit/resolve/delete. Not exported by default.

**Spellcheck** — Book-local dictionary (`spell/en.add`). Spellcheck only in chapter prose.

**Export** — Pandoc-based (EPUB/DOCX). Assembles ordered chapters into manuscript. Outputs to `exports/builds/`.

**Neovide Polish** — Optional variable-width fonts, line spacing, smooth animations for a manuscript feel on Neovide.

## Progress

See `Tadafile` for detailed phase breakdown and progress tracking.
