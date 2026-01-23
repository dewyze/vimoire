# Vimoire Configuration

Vimoire loads user configuration from `~/.vimoire/config.lua`. This file is separate from the app code (which lives in `~/.config/vimoire/` via `NVIM_APPNAME`).

## Example Configuration

```lua
-- ~/.vimoire/config.lua
return {
  colorscheme = "vimoire-parchment",
  keymaps = {
    finder = {
      navigate = "<C-p>",
    },
  },
  editor = {
    textwidth = 72,
  },
}
```

Only include the settings you want to override. Everything else uses defaults.

## Options Reference

### colorscheme

Default: `"vimoire-inkwell"`

Available themes:
- `vimoire-inkwell` — warm dark (default)
- `vimoire-parchment` — warm light
- `vimoire-vellum` — sepia
- `vimoire-umbra` — high contrast monochrome dark
- `vimoire-lumen` — high contrast monochrome light

You can also set the theme at runtime with `:VimoireTheme`.

### keymaps

#### keymaps.finder

Pickers for navigating your manuscript.

| Key | Default | Description |
|-----|---------|-------------|
| `navigate` | `<leader>ff` | All items |
| `manuscript` | `<leader>fm` | Manuscript entries only |
| `characters` | `<leader>fc` | Characters folder |
| `settings` | `<leader>fp` | Settings folder |
| `reference` | `<leader>fr` | Reference folder |
| `exports` | `<leader>fe` | Export output files |

Set any key to `false` to disable it.

#### keymaps.navigator

Neo-tree sidebar controls.

| Key | Default | Description |
|-----|---------|-------------|
| `toggle` | `<LocalLeader>nt` | Toggle tree visibility |
| `reveal` | `<LocalLeader>nf` | Reveal current file in tree |
| `manuscript` | `gvm` | Switch to manuscript view |
| `export` | `gve` | Switch to export view |

#### keymaps.views

| Key | Default | Description |
|-----|---------|-------------|
| `home` | `gvh` | Show dashboard |
| `focus` | `gvf` | Toggle focus mode |

#### keymaps.snippets

Snippet management for the current chapter/page.

| Key | Default | Mode | Description |
|-----|---------|------|-------------|
| `browse` | `<leader>fs` | normal | Browse and insert snippets |
| `extract` | `<leader>xs` | visual | Cut selection to snippet |

#### keymaps.buffer

Buffer-level actions for the current file.

| Key | Default | Description |
|-----|---------|-------------|
| `notes` | `<leader>N` | Open notes for current chapter/page |
| `marks` | `<leader>M` | Browse marks in current buffer |
| `toggle_kind` | `<leader>T` | Toggle chapter/page for current entry |

### editor

Settings applied to prose and markdown buffers.

| Key | Default | Description |
|-----|---------|-------------|
| `textwidth` | `80` | Text width for formatting |
| `scrolloff` | `5` | Lines to keep above/below cursor |
| `tabstop` | `4` | Tab display width |
| `shiftwidth` | `4` | Indent width |
| `wrap` | `true` | Soft wrap long lines |
| `linebreak` | `true` | Wrap at word boundaries |
| `visual_line_navigation` | `true` | Map j/k to gj/gk (navigate visual lines) |

### ui

| Key | Default | Description |
|-----|---------|-------------|
| `mouse_mode` | `"single_click"` | Tree open behavior: `"single_click"` or `"double_click"` |

### finder

| Key | Default | Description |
|-----|---------|-------------|
| `preview` | `true` | Show file preview in picker |

### export

| Key | Default | Description |
|-----|---------|-------------|
| `auto_open` | `true` | Open exported file after successful export |

Use `--no-open` flag to skip auto-open for a single export: `:VimoireExport --no-open`

### neovide

Settings for Neovide (ignored in terminal Neovim).

| Key | Default | Description |
|-----|---------|-------------|
| `font` | `"Iosevka Term Slab:h16"` | Font family and size |
| `linespace` | `8` | Extra line spacing |
| `padding.top` | `20` | Window padding |
| `padding.left` | `20` | Window padding |
| `padding.right` | `20` | Window padding |
| `padding.bottom` | `20` | Window padding |
| `scroll_animation_length` | `0.3` | Scroll animation duration |

## Neo-tree Keymaps

These keymaps are active when focused on the manuscript tree. They are not configurable.

| Key | Action |
|-----|--------|
| `<CR>` / `o` | Open file or toggle folder |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `t` | Toggle folder |
| `C` | Close folder |
| `z` | Close all folders |
| `e` | Expand all folders |
| `q` | Close tree |
| `?` | Show help |
| `R` | Refresh |
| `a` | Add (chapter, page, section) |
| `r` | Rename |
| `d` | Delete |
| `n` | Open notes |
| `m` | Move (not yet implemented) |
| `J` / `K` | Reorder down/up |
| `T` | Toggle chapter/page |
