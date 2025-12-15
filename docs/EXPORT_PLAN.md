# Export Implementation Plan

Step-by-step implementation order for the export pipeline.

---

## Phase 1: Template Files

Create static template assets in `app/templates/export/`. These are used directly during development and copied to projects by scaffolding later.

### 1.1 epub.css
Basic ebook typography:
- Body: readable font stack, line-height, margins
- h1: chapter headings (centered or styled)
- hr: scene breaks (subtle, centered)
- Fenced div styles: `.epigraph`, `.letter` (indented, italicized)

~50 lines. Keep it simple—older ereaders have limited CSS support.

### 1.2 pagebreak.lua
Pandoc Lua filter for DOCX page breaks:
- Matches RawBlock with `\newpage`
- Outputs OOXML page break

~10 lines. Required for DOCX—without it, page breaks don't work.

### 1.3 reference.docx
Word document with predefined styles:
- Normal (body text)
- Heading 1, 2, 3
- First Paragraph (no indent after heading)
- Block Text (quotes, letters)

Create manually or generate via pandoc and modify. Pandoc applies these styles to output.

---

## Phase 2: Preprocessor

Pure text transformation functions. No file I/O, no pandoc—just string in, string out.

### 2.1 Paragraph breaks
```
Input:  "Line one\nLine two"
Output: "Line one\n\nLine two"
```
Single newlines → double newlines for markdown paragraph breaks.

### 2.2 Chapter numbering
```
Input:  "# Chapter {{chapter.num}}: The Beginning"
Context: {chapter_num = 3}
Output: "# Chapter 3: The Beginning"
```
Replace `{{chapter.num}}` with the running chapter count (passed in as context).

### 2.3 Strip marks and todos
```
Input:  "He walked {{mark}}slowly to the {{todo:fix pacing}}door."
Output: "He walked slowly to the door."
```
Remove `{{mark}}`, `{{mark:...}}`, `{{todo}}`, `{{todo:...}}`. Strips optional trailing newline.

### 2.4 Variable substitution (front/back matter)
```
Input:  "Copyright {{book.copyright}}\nby {{book.author}}"
Context: {book = {copyright = "© 2025", author = "Jane Doe"}}
Output: "Copyright © 2025\nby Jane Doe"
```
Replace `{{book.title}}`, `{{book.author}}`, `{{book.copyright}}`, etc. from book.yml values.

### 2.5 Module interface
```lua
local preprocess = require("vimoire.export.preprocess")

-- For prose entries
local output = preprocess.prose(content, {
  chapter_num = 3,  -- nil for pages
})

-- For front/back matter
local output = preprocess.matter(content, {
  book = book,  -- book.yml data
})
```

---

## Phase 3: Collector

Walk manuscript.json, build ordered file list with context for each entry.

### 3.1 Entry collection
```lua
local collector = require("vimoire.export.collector")

local entries = collector.collect(state)
-- Returns:
-- {
--   {id = "chap1a", path = "/path/to/entries/chap1a/prose.md", chapter_num = 1},
--   {id = "intrlud", path = "/path/to/entries/intrlud/prose.md", chapter_num = nil},
--   {id = "chap1b", path = "/path/to/entries/chap1b/prose.md", chapter_num = 2},
-- }
```

- Walks manuscript.json items recursively (sections are containers, entries are leaves)
- Tracks running chapter count (chapters increment, pages don't)
- Returns flat ordered list with paths and context

### 3.2 Chapter vs page detection
Uses existing item type info from manuscript structure. Chapters get `chapter_num`, pages get `nil`.

---

## Phase 4: EPUB Export

First format. Simpler than DOCX—no page breaks needed.

### 4.1 Pipeline
1. Collect entries via collector
2. For each entry: read file, preprocess with context
3. Write preprocessed content to temp files
4. Build pandoc command
5. Execute, capture output
6. Move result to `exports/builds/`

### 4.2 Pandoc command
```bash
pandoc temp1.md temp2.md temp3.md \
  --standalone \
  --split-level=1 \
  --css=/path/to/epub.css \
  --metadata title="Book Title" \
  --metadata author="Author Name" \
  --metadata lang="en" \
  -o exports/builds/BookTitle.epub
```

### 4.3 Basic error handling
- Check pandoc exists
- Capture stderr to `exports/builds/export.log`
- Report success/failure via `vim.notify`

---

## Phase 5: DOCX Export

Second format. Adds page breaks and reference doc.

### 5.1 Page break injection
After preprocessing each entry, append `\newpage` raw block:

```markdown
...entry content...

```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```
```

Or use `\newpage` and let the Lua filter convert it.

### 5.2 Pandoc command
```bash
pandoc temp1.md temp2.md temp3.md \
  --standalone \
  --reference-doc=/path/to/reference.docx \
  --lua-filter=/path/to/pagebreak.lua \
  -o exports/builds/BookTitle.docx
```

### 5.3 Module interface
```lua
local export = require("vimoire.export")

export.run({
  format = "epub",  -- or "docx"
  -- Later: entries, front_matter, back_matter from config
})
```

---

## Phase 6: Export Config

YAML config system for customizable exports.

### 6.1 Config generation
`:VimoireExportConfig` generates `exports/configs/default.yml`:
```yaml
format: epub

entries:
  - chap1a    # The Beginning (chapter 1)
  - intrlud   # Interlude (page)
  - chap1b    # The Middle (chapter 2)
```

- Walks current manuscript state
- Adds comments showing entry name and chapter/page status
- Opens file for editing

### 6.2 Config parsing
Read YAML, resolve entry IDs, skip commented lines.

### 6.3 Regeneration
When regenerating existing config:
- Preserve `format` and `output` settings
- Regenerate entries from current manuscript order
- Keep previously commented entries commented (match by ID)

### 6.4 Named configs
```
:VimoireExportConfig submission  → exports/configs/submission.yml
:VimoireExport submission        → runs that config
```

---

## Phase 7: Front/Back Matter

### 7.1 Directory structure
```
front_matter/
  title.md
  copyright.md
  dedication.md
back_matter/
  acknowledgments.md
  about_author.md
```

### 7.2 Integration
- Add to config generation (list files from directories)
- Preprocess with book.yml variables
- Include in pandoc input (before/after entries)

### 7.3 Scaffolding defaults
TBD: What files to scaffold by default, template content.

---

## Phase 8: Scaffolding

Copy export templates to new projects.

### 8.1 Files to scaffold
```
templates/
  epub.css
  reference.docx
  pagebreak.lua
exports/
  configs/.gitkeep
  builds/.gitkeep
front_matter/.gitkeep
back_matter/.gitkeep
```

### 8.2 Update scaffold module
Add export-related files/directories to project creation.

---

## Phase 9: Commands & Polish

### 9.1 Commands
- `:VimoireExportConfig [name]` — generate/open config
- `:VimoireExport [name]` — run export

### 9.2 Auto-open
After successful export, open result:
- macOS: `open`
- Linux: `xdg-open`
- Disable with `--no-open` flag or config setting

### 9.3 Error handling
- Missing pandoc: error with install instructions
- Invalid config: validation errors in quickfix
- Missing files: warn and skip, continue export
- Pandoc errors: capture to log, show summary

---

## Open Questions

1. **Front/back matter defaults:** What files to scaffold? What template content?
2. **Chapter titles:** Pull from first H1 in prose, or from entry name in manuscript.json?
3. **Config location:** `exports/configs/` or simpler `exports/`?

---

## Dependencies

- **pandoc** — external, user must install
- **plenary.nvim** — for `plenary.job` (async shell), `plenary.path`
- **tinyyaml** — already vendored, for config parsing
