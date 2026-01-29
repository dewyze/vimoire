# Plotting System Research

Research for a grid-based plotting feature in Vimoire.

---

## Use Case

Writers use spreadsheet-style grids for plotting. The canonical example is J.K. Rowling's Order of the Phoenix spreadsheet:
- **Rows**: Chapters
- **Columns**: Plot threads (Prophecy, DA, Romance, etc.)
- **Cells**: Short notes about what happens in that chapter for that thread

Grids could also be per-chapter (rows = characters, columns = story beats) or any freeform structure the writer wants.

---

## Requirements

### Core
- **Freeform grids**: Not tied to manuscript structure, user defines rows/columns
- **Multiple boards**: N boards per book, each with unique ID + name
- **Scope**: Manuscript-level boards (shown in neo-tree under "Plotting" section), potentially chapter-level boards later
- **Cell content**: First line visible in grid, full content on expand (K or popup)
- **Storage**: JSON files with random IDs (like other planning items)
- **Display**: Opens in buffer, replacing current view

### Interaction
- `hjkl`: Navigate between cells
- `Shift+hjkl`: Move rows/columns
- `<CR>` or `e`: Edit cell in popup
- New row/column: Navigate past edge to create (empty rows/columns don't persist)
- Standard vim: `yy`/`p` for copy/paste rows, etc.

### Display
- Box-drawing character grid (clear cell boundaries)
- Column widths: Auto-size with configurable max
- First row = column headers, first column = row labels
- Headers styled differently (bold/color)

### Future Enhancements (not MVP)
- Hashtags for filtering (`#character`, `#setting`)
- Color coding
- Links to planning documents
- Frozen headers on scroll
- Chapter-level boards with badge indicators

---

## Existing Solutions Evaluated

### nui.nvim Table
**Source**: Already a dependency (via neo-tree)

Renders beautiful bordered tables:
```
┌──────────┬─────────────┬─────────────┐
│ Header 1 │ Header 2    │ Header 3    │
├──────────┼─────────────┼─────────────┤
│ Cell     │ Cell        │ Cell        │
└──────────┴─────────────┴─────────────┘
```

**Verdict**: Display-only. Sets buffer to `readonly = true, modifiable = false`. Would need significant extension to support editing. Good reference for rendering patterns.

---

### Kanban Plugins

**[super-kanban.nvim](https://github.com/hasansujon786/super-kanban.nvim)**
- Keyboard-centric kanban with treesitter parsing
- Obsidian-compatible markdown storage
- Columns only (Todo → Doing → Done), not a 2D grid

**[kanban.nvim](https://github.com/arakkkkk/kanban.nvim)**
- Similar feature set, markdown storage
- Telescope integration for searching boards

**Verdict**: Wrong paradigm. Kanban is column-based workflow stages. We need a true 2D grid where both axes are user-defined.

---

### CSV/Table Editors

**[csvview.nvim](https://github.com/hat0uma/csvview.nvim)**
- Virtual text alignment for CSV files
- Sticky headers, field-aware text objects
- Navigation with Tab/Enter

**Verdict**: View/navigate only, not a full editor. Designed to make vim editing CSV easier, not to be a spreadsheet.

**[table-nvim](https://github.com/SCJangra/table-nvim)**
- Markdown table editor, formats as you type
- Add/remove rows and columns
- Tab/Shift-Tab navigation

**Verdict**: Closest to what we want, but markdown tables get ugly with longer content. Also limited to markdown format (we want JSON storage).

**[edit-markdown-table.nvim](https://github.com/kiran94/edit-markdown-table.nvim)**
- Opens cell content in popup for editing
- Treesitter-based

**Verdict**: Good UX pattern (popup editing), but tied to markdown format.

---

### External Spreadsheet Tools

**[sc-im](https://github.com/andmarti1424/sc-im)**
- Full terminal spreadsheet with vim bindings
- Lua 5.1 scripting support
- Formulas, CSV/XLSX import/export

**[sc-im.nvim](https://github.com/DAmesberger/sc-im.nvim)**
- Neovim plugin to edit markdown tables via sc-im
- Bidirectional sync, formula preservation

**Verdict**: Overkill. sc-im is a full spreadsheet calculator. We don't need formulas or Excel compatibility. Also requires external dependency.

**[VisiData](https://github.com/saulpw/visidata)**
- Terminal data multitool (CSV, JSON, SQLite, etc.)
- Python-based, very powerful

**[visidata.nvim](https://github.com/Willem-J-an/visidata.nvim)**
- Integration for pandas dataframes in nvim-dap

**Verdict**: Wrong tool. VisiData is for data analysis, not authoring. Terminal-based, would need to run in Neovim terminal buffer.

---

## Recommendation: Roll Our Own

None of the existing solutions fit well:
- Kanban plugins: Wrong paradigm (1D columns, not 2D grid)
- CSV/markdown editors: Tied to specific formats, limited editing
- External tools: Overkill, external dependencies, wrong use case

### Build on nui.nvim primitives

We already have nui.nvim. Use its building blocks:
- `nui.popup` for cell editing dialogs
- `nui.text` / `nui.line` for styled content
- Borrow rendering patterns from `nui.table` (box characters, alignment)

### Architecture Sketch

```
lua/vimoire/
├── plotting/
│   ├── init.lua          -- Public API
│   ├── board.lua         -- Board object (data model)
│   ├── cell.lua          -- Cell object
│   ├── renderer.lua      -- Grid rendering (box chars, extmarks)
│   ├── editor.lua        -- Cell editing popup
│   ├── navigation.lua    -- hjkl movement, cell boundaries
│   └── persistence.lua   -- JSON load/save
```

### Data Model (JSON)

```json
{
  "id": "abc123",
  "name": "Master Plot Grid",
  "columns": [
    { "id": "col1", "header": "" },
    { "id": "col2", "header": "Prophecy" },
    { "id": "col3", "header": "DA" },
    { "id": "col4", "header": "Romance" }
  ],
  "rows": [
    {
      "id": "row1",
      "cells": {
        "col1": "Ch 1",
        "col2": "Dementors attack\n\nHarry uses patronus, sets up hearing",
        "col3": "",
        "col4": "Cho mentioned in passing"
      }
    },
    {
      "id": "row2",
      "cells": {
        "col1": "Ch 2",
        "col2": "",
        "col3": "Idea planted",
        "col4": ""
      }
    }
  ]
}
```

### Display Rendering

```
┌────────┬─────────────────┬─────────────────┬─────────────────┐
│        │ Prophecy        │ DA              │ Romance         │
│        │                 │                 │                 │
├────────┼─────────────────┼─────────────────┼─────────────────┤
│ Ch 1   │ Dementors att…  │                 │ Cho mentioned   │
│        │ Harry uses pa…  │                 │ in passing      │
├────────┼─────────────────┼─────────────────┼─────────────────┤
│ Ch 2   │                 │ Idea planted    │                 │
│        │                 │ by Hermione     │                 │
└────────┴─────────────────┴─────────────────┴─────────────────┘
```

- Cells show 2-3 lines of content (configurable), truncated with `…` if more
- Column widths: `max(header_width, max_cell_content_width, min_width)` capped at `max_width`
- Empty cells render as whitespace
- Current cell highlighted (cursor)

### Scrolling

Grids will often be wider/taller than the window. Need viewport scrolling:

- **Horizontal**: When cursor moves past visible columns, viewport shifts
- **Vertical**: When cursor moves past visible rows, viewport shifts
- **Frozen headers** (post-MVP): First row (column headers) AND first column (row labels) stay visible while scrolling—like Excel's freeze panes. Without this, scrolling right loses row context.

Viewport state tracked separately from cursor position:
```lua
{
  cursor = { row = 3, col = 5 },      -- Current cell
  viewport = { row = 1, col = 2 },    -- Top-left visible cell
  visible = { rows = 10, cols = 4 }   -- How many fit in window
}
```

Navigation auto-scrolls to keep cursor visible. Could also support `zz`/`zt`/`zb` style commands to manually adjust viewport.

### Keymaps

| Key | Action |
|-----|--------|
| `h/j/k/l` | Move cursor between cells |
| `H/J/K/L` | Move current row/column |
| `<CR>` or `e` | Edit cell (opens popup) |
| `K` | Preview full cell content (hover/popup) |
| `o` | Add row below |
| `O` | Add row above |
| `a` | Add column right |
| `A` | Add column left |
| `dd` | Delete current row |
| `dc` | Delete current column |
| `q` | Close board |

### File Structure

```
book_root/
├── plotting/
│   ├── abc123.json    -- "Master Plot Grid"
│   └── def456.json    -- "Character Arcs"
```

Boards listed in `manuscript.json`:
```json
{
  "plotting": [
    { "id": "abc123", "name": "Master Plot Grid" },
    { "id": "def456", "name": "Character Arcs" }
  ]
}
```

### Neo-tree Integration

New "Plotting" section at manuscript level:
```
📖 Manuscript
├── ...
├── 📚 Reference
└── 📊 Plotting
    ├── Master Plot Grid
    └── Character Arcs
```

Clicking opens board in current buffer.

---

## Effort Estimate

This is a medium-sized feature. Main work areas:

1. **Renderer** (hardest): Drawing the grid, handling variable column widths, truncation, cursor highlighting
2. **Navigation**: Tracking cell positions, boundary detection
3. **Editor popup**: Straightforward with nui.popup
4. **Persistence**: JSON read/write, manuscript.json integration
5. **Neo-tree integration**: New node type, similar to existing planning sections

nui.nvim gives us the popup and text primitives. The grid rendering is the novel part—we'd essentially be writing a simpler, editable version of nui.table.

---

## Open Questions

1. **Chapter-level boards**: How to indicate/access? Badge on chapter line? Command? Defer to post-MVP?

2. **Large grids**: Scrolling is required (see above). Frozen row/column headers are post-MVP but well-defined.

3. **Column resize**: Allow manual resize? Or just auto + max? Manual resize adds complexity.

4. **Undo/redo**: Per-cell? Per-board? Neovim's native undo won't work well since we're managing our own buffer content.

---

## References

- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) - UI component library (popup, table rendering)
- [super-kanban.nvim](https://github.com/hasansujon786/super-kanban.nvim) - Keyboard-centric kanban
- [csvview.nvim](https://github.com/hat0uma/csvview.nvim) - CSV viewing with virtual text
- [table-nvim](https://github.com/SCJangra/table-nvim) - Markdown table editing
- [sc-im](https://github.com/andmarti1424/sc-im) - Terminal spreadsheet
