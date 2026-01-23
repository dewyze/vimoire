# Help Documentation

## Summary

Create exhaustive, navigable help documentation accessible via `:help vimoire` or `:Help`.

## Access Points

1. **`:help vimoire`** — opens main help (vim's native help system)
2. **`:Help`** — alias, easier to type
3. **`?` in neotree** — context-sensitive help for navigator
4. **`?` in pickers** — context-sensitive help for current picker

## Content Structure

### Getting Started
- Installation
- Opening your first manuscript
- Creating a new manuscript
- Basic workflow: write → organize → export

### Concepts
- **Manuscript structure** — entries, sections, chapters, pages
- **Planning** — characters, settings, reference, subfolders
- **Exports** — configs, templates, output formats
- **Focus mode** — distraction-free writing

### Keymaps
- Complete keymap reference
- Organized by domain (navigation, editing, finding, export)
- Display line vs buffer line behaviors
- Customization via `~/.vimoire/config.lua`

### Commands
- All commands with descriptions
- Examples of usage
- Command palette access

### Navigation
- Neo-tree manuscript view
- Neo-tree export view
- Finders (telescope/snacks pickers)
- Moving between entries

### Editing
- Prose-specific behaviors
- Marks system
- Snippets
- Images

### Export
- Config file format
- Supported formats (epub, docx)
- Templates customization
- Pandoc requirements

### Configuration
- `~/.vimoire/config.lua` options
- Colorschemes
- Keybind customization
- Editor settings

### Troubleshooting
- Common issues
- Log locations
- Reporting bugs

## Implementation Options

### Option 1: Vim Help Files
Standard `:help` integration using vim's help format.

```
doc/
  vimoire.txt        — main entry point
  vimoire-keys.txt   — keymap reference
  vimoire-commands.txt
  vimoire-export.txt
  ...
```

Pros:
- Native vim experience
- Supports tags/links (`|vimoire-export|`)
- Searchable with `:helpgrep`

Cons:
- Vim help syntax is arcane
- Less pretty than markdown

### Option 2: Floating Markdown Window
Custom help viewer that renders markdown in a floating window.

Pros:
- Prettier
- Easier to write/maintain
- Can include formatting

Cons:
- Custom implementation needed
- Not searchable via `:helpgrep`

### Option 3: Both
- Vim help files for `:help vimoire`
- Nice floating viewer for `:Help` command
- Generate one from the other?

## Navigation

Help should have "buttons" (links) for jumping between sections:

```
Vimoire Help                                     *vimoire*

  |vimoire-quickstart|     Getting started
  |vimoire-keymaps|        Keymap reference
  |vimoire-commands|       Command reference
  |vimoire-export|         Export system
  |vimoire-config|         Configuration
```

Clicking/pressing enter on `|vimoire-keymaps|` jumps to that section.

## Context-Sensitive Help

### Neo-tree (`?`)
Already shows keymaps for current view. Could enhance with:
- Brief descriptions
- Link to full docs

### Pickers (`?`)
Show available actions in current picker:
- Insert snippet
- Edit snippet
- Delete snippet
- etc.

## Open Questions

1. Generate help from source code/comments?
2. Include help in command palette?
3. Web version of docs for non-vim browsing?
4. Localization (probably not for MVP)?
