# Vimoire — Export Spec

Export pipeline for assembling and converting manuscripts to publishable formats.

---

## Overview

Export uses a config-file-based workflow. Generate a YAML config that lists everything going into the export — format and entries. Edit the config to customize, then run the export. Save named configs for different purposes (submission, ebook, beta readers).

---

## Formats

| Format | Output | Use case |
|--------|--------|----------|
| EPUB | Single `.epub` file | Ebooks, Kindle (via Calibre), ereaders, self-pub platforms |
| DOCX | Single `.docx` file | Agent/editor submissions, manuscript format |

All formats require pandoc.

---

## Project Structure

Scaffolding creates these export-related files/folders:

```
book.yml                    # book identity (see BOOK_YML_SPEC.md)
exports/                    # export configs, templates, and output (gitignored)
  templates/                # export styling
    chapter.md              # chapter opening template (see Chapter Frontmatter)
    epub.css
    reference.docx
    pagebreak.lua           # pandoc filter for DOCX page breaks
  configs/
    default.yml             # generated on first export
  output/
    MyNovel.epub
    MyNovel.docx
    export.log
```

---

## book.yml

See `BOOK_YML_SPEC.md` for full specification. Export reads title, author, language, and optional metadata (copyright, publisher, isbn) from this file.

---

## Export Config

The export config is a YAML file that defines exactly what goes into an export. Generated from current manuscript state, then editable.

**Example: `exports/configs/default.yml`**

```yaml
format: epub  # epub | docx

# output: MyNovel.epub  # default: {title}.{format}

entries:
  - titlep     # Title Page (page)
  - copyrtp    # Copyright (page)
  - part1tp    # Part One (page)
  - chap1a     # The Day I Became Sentient (chapter 1)
  - chap1b     # Bread: A Love Story (chapter 2)
  - intrlud    # Interlude (page)
  - chap2a     # Exile in the Drawer (chapter 3)
  - chap2b     # The Crumb Rebellion (chapter 4)
  - epilog1    # Epilogue (page)
  - acknwlg    # Acknowledgments (page)
```

**Key points:**

- **Everything visible:** All content going into the export is listed explicitly
- **Comment to exclude:** Comment out any line to exclude it from export
- **Entries are flattened:** Sections are organizational only — they don't appear in export. Entries listed in manuscript order.
- **Entry comments:** Show `(chapter N)` for chapters and `(page)` for pages to help identify content.

**Regeneration behavior:**

Running `:VimoireExportConfig` on an existing config:
- Preserves `format` and `output` settings
- Regenerates `entries` list from current manuscript.json order
- Keeps previously commented-out entries commented (matched by ID)

---

## UX Flow

**First export:**

1. Run `:VimoireExportConfig` — generates `exports/configs/default.yml` and opens it
2. Review the config — see format and all entries in order
3. Edit if needed — change format, comment out entries to exclude, etc.
4. Run `:VimoireExport` — executes the default config, outputs to `exports/output/`

**Named configs for different purposes:**

```
:VimoireExportConfig submission    → generates/opens exports/configs/submission.yml
:VimoireExport submission          → runs that config
```

Use cases:
- `submission.yml` — DOCX, first three chapters only
- `beta-readers.yml` — EPUB, full manuscript
- `sample.yml` — EPUB, chapters 1-5 for preview

---

## Front/Back Matter

No special front/back matter system. Users create Pages (via neotree) for title pages, copyright, dedication, acknowledgments, etc. These appear in the manuscript and export config like any other entry.

Use template variables in any Page:
- `{{book.title}}` — book title from book.yml
- `{{book.author}}` — author name
- `{{book.language}}` — language code

Example title page (create as a Page, move to top of manuscript):
```markdown
# {{book.title}}

by {{book.author}}
```

---

## Templates

Scaffolded with working defaults — first export should look decent without customization.

**epub.css:**
- Clean, readable typography
- Sensible margins
- Styled chapter headings (h1)
- Scene breaks (hr or styled ***)
- Block styling for fenced divs (letter, epigraph, etc.)

**reference.docx (optional):**
- Not scaffolded by default — pandoc uses sensible built-in styles
- To customize DOCX styling, create `exports/templates/reference.docx`
- Generate a starter with: `pandoc -o reference.docx --print-default-data-file reference.docx`
- Edit in Word to set paragraph styles (Normal, Heading 1-3), fonts, margins, line spacing
- Vimoire will automatically use it if present

User customization: edit these files directly. No separate "user override" location — book templates are the source of truth.

---

## Chapter Frontmatter

Chapters use YAML frontmatter to control their appearance in export. When creating a new chapter, prose.md is scaffolded with:

```yaml
---
title: Chapter Name
# subtitle:
# epigraph:
---
```

**Fields:**

- `title` — Display title for export. Overrides the name in manuscript.json (which is the "working title" for navigation).
- `subtitle` — Optional. Shown below the title in chapter openings.
- `epigraph` — Optional. A quote or motto to open the chapter.

**Chapter Template:**

The chapter opening format is controlled by `exports/templates/chapter.md`. Default:

```markdown
# Chapter {{num}}: {{title}}

```

Customize this to change how chapter headings render. Available placeholders:

- `{{num}}` — Chapter number (1, 2, 3...)
- `{{title}}` — From frontmatter.title (falls back to manuscript.json name)

**Name vs Title:**

- **Name** (manuscript.json) — Working title for the navigator. "climax battle", "ch7 draft", etc.
- **Title** (frontmatter) — Display title for readers. "Chapter Seven: The Last Stand"

These can be the same or different. Renaming in the navigator changes the name; editing frontmatter changes the title.

---

## Pipeline

What happens when you run `:VimoireExport`:

### Step 1: Read Config

Parse the export config YAML. Validate format, resolve entry IDs to file paths.

### Step 2: Collect Files

Build ordered file list from config. Entry IDs resolve to `entries/{id}/prose.md` on disk.

Missing files: warn and skip. Invalid entry IDs: warn and skip.

### Step 3: Preprocess Each File

| Transform | Input | Output |
|-----------|-------|--------|
| Paragraph breaks | `\n` | `\n\n` |
| Chapter number | `{{chapter.num}}` | Running count (chapters only, pages don't increment) |
| Book variables | `{{book.title}}`, `{{book.author}}` | Values from book.yml |
| Marks | `{{mark}}`, `{{mark:text}}` | Stripped |
| Todos | `{{todo}}`, `{{todo:text}}` | Stripped |

Chapter numbering example: Page, Chapter, Chapter, Page, Chapter → chapters numbered 1, 2, 3.

### Step 4: Format-Specific Processing

**EPUB:**
- Use `--split-level=1` so each H1 becomes a separate XHTML file in the EPUB bundle (proper ebook structure, better ereader navigation)

**DOCX:**
- Inject `\newpage` between entries
- Apply `pagebreak.lua` filter to convert to proper OOXML page breaks

### Step 5: Call Pandoc

EPUB:
```bash
pandoc input_files... \
  --split-level=1 \
  --css=exports/templates/epub.css \
  --metadata title="..." --metadata author="..." --metadata lang="..." \
  -o exports/output/Title.epub
```

DOCX:
```bash
pandoc input_files... \
  --reference-doc=exports/templates/reference.docx \
  --lua-filter=exports/templates/pagebreak.lua \
  -o exports/output/Title.docx
```

---

## Commands

**Config management:**
```
:VimoireExportConfig              " generate/open default.yml
:VimoireExportConfig submission   " generate/open submission.yml
```

**Run export:**
```
:VimoireExport                    " run default config
:VimoireExport submission         " run named config
```

---

## Output

- **Location:** `exports/output/`
- **Filename:** `{output}` from config, or `{title}.{format}` (title from book.yml, sanitized for filesystem)
- **Log:** `exports/output/export.log` (pandoc stderr)
- **Auto-open:** After successful export, opens result (macOS `open`, Linux `xdg-open`). Disable with `:VimoireExport --no-open` or config setting.

---

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Missing pandoc | Error with install instructions |
| Missing book.yml | Error with scaffold instructions |
| Invalid config YAML | Validation errors in quickfix |
| Missing entry file | Warn and skip (partial export continues) |
| Entry ID not in manuscript.json | Warn and skip |
| Pandoc errors | Capture stderr to `exports/output/export.log`, show summary in Neovim |

Errors surface via `vim.notify`. Detailed logs in `export.log`.

---

## Implementation Phases

### Phase 1: Core Pipeline
- [x] Read book.yml metadata
- [x] Walk manuscript.json, collect entry prose.md paths in order
- [x] Implement preprocessing (newlines, {{chapter.num}}, strip tags)
- [x] Write preprocessed files to temp directory
- [x] Shell out to pandoc (EPUB first)
- [x] Write to exports/output/

### Phase 2: Export Config
- [x] Define config YAML schema
- [x] Generate config from manuscript state
- [x] Parse config for export
- [x] Regenerate while preserving customizations (commented entries)
- [x] :VimoireExportConfig command

### Phase 3: DOCX Format
- [x] DOCX with page breaks
- [x] Format-specific pandoc flags (via format objects)

### Phase 4: Templates & Filters
- [x] Scaffold default templates at project creation
- [x] Bundle pagebreak.lua filter
- [x] Default epub.css
- [x] Exports searchable in telescope
> reference.docx not scaffolded — optional, pandoc uses built-in defaults

### Phase 5: Commands & Polish
- [x] :VimoireExport command
- [ ] Auto-open with opt-out
- [ ] Error handling and quickfix integration

---

## Deferred

- HTML multi-page export (TOC, prev/next navigation)
- PDF export (requires LaTeX)
- Standalone CLI script for headless/CI usage
- Custom pandoc flags per-format in config
- Template customization documentation
- Progress indication for large manuscripts
- Word count in output
