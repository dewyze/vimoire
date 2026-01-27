# Vimoire Configuration

Vimoire loads user configuration from `~/.vimoire/config.lua`. This file is separate from the app code (which lives in `~/.config/vimoire/` via `NVIM_APPNAME`).

Only include settings you want to override. Everything else uses defaults.

## Complete Default Configuration

```lua
-- ~/.vimoire/config.lua
return {
  colorscheme = "inkwell",

  keymaps = {
    palette = "<leader>p",
    finder = {
      smart = { "<leader>ff", "<C-p>" },
      manuscript = "<leader>fm",
      planning = "<leader>fp",
      snippets = "<leader>fs",
      exports = "<leader>fe",
    },
    navigator = {
      toggle = "<leader>nt",
      reveal = "<leader>nf",
      manuscript = "<leader>nm",
      export = "<leader>ne",
    },
    views = {
      home = "<leader>vh",
      focus = "<leader>vf",
    },
    writing = {
      notes = "<leader>wn",
      marks = "<leader>wm",
      toggle_kind = "<leader>wk",
      prose = "<leader>ww",
    },
    insert = {
      mark = "<leader>im",
      image = "<leader>ii",
    },
    snippets = {
      insert = "<leader>si",
      extract = "<leader>sx",
    },
    misc = {
      clear_highlight = "<Esc><Esc>",
    },
  },

  ui = {
    mouse_mode = "single_click",
  },

  editor = {
    textwidth = 86,
    scrolloff = 5,
    tabstop = 4,
    shiftwidth = 4,
    wrap = true,
    linebreak = true,
    visual_line_navigation = true,
    autosave = false,
    focus_mode = true,
    termguicolors = true,
  },

  finder = {
    preview = true,
  },

  export = {
    auto_open = true,
  },

  neovide = {
    font = "Iosevka Term Slab:h16",
    linespace = 8,
    padding = {
      top = 20,
      left = 20,
      right = 20,
      bottom = 20,
    },
    scroll_animation_length = 0.3,
  },
}
```

---

## plugins

Add custom plugins using lazy.nvim spec format:

```lua
return {
  plugins = {
    { "tpope/vim-surround" },
    { "github/copilot.vim" },
    {
      "some/plugin",
      opts = { ... },
      config = function() ... end,
    },
  },
}
```

Standard lazy.nvim options work: `opts`, `config`, `lazy`, `event`, `keys`, etc. See [lazy.nvim docs](https://lazy.folke.io/spec) for full spec format.

**Note:** Adding plugins may affect Vimoire's behavior. Plugins that override keymaps, colorschemes, or UI elements may conflict with built-in functionality.

---

## colorscheme

Default: `"inkwell"`

Available themes:

**Dark:**
- `inkwell` — warm candlelight (default)
- `umbra` — high contrast monochrome
- `abyss` — ocean blues
- `hollow` — forest greens
- `dusk` — twilight purples
- `tempest` — storm grays
- `hearth` — firelight reds
- `nebula` — cosmic purples
- `frost` — arctic blues

**Light:**
- `parchment` — warm cream
- `vellum` — aged sepia
- `lumen` — high contrast monochrome

You can also change themes at runtime with `:Theme`.

---

## keymaps

All keymaps use `<leader>` with mnemonic prefixes. Set any key to `false` to disable it, or use an array to bind multiple keys to the same action:

```lua
keymaps = {
  misc = {
    clear_highlight = { "<Esc><Esc>", "<leader>nh" },  -- both work
  },
}
```

### keymaps.palette

| Key | Default | Description |
|-----|---------|-------------|
| `palette` | `<leader>p` | Open command palette |

### keymaps.finder

Pickers for navigating your manuscript.

| Key | Default | Description |
|-----|---------|-------------|
| `smart` | `{ "<leader>ff", "<C-p>" }` | Context-aware: all items |
| `manuscript` | `<leader>fm` | Manuscript entries only |
| `planning` | `<leader>fp` | All planning items |
| `snippets` | `<leader>fs` | Browse snippets |
| `exports` | `<leader>fe` | Export output files |

### keymaps.navigator

Neo-tree sidebar controls.

| Key | Default | Description |
|-----|---------|-------------|
| `toggle` | `<leader>nt` | Toggle tree visibility |
| `reveal` | `<leader>nf` | Reveal current file in tree |
| `manuscript` | `<leader>nm` | Switch to manuscript view |
| `export` | `<leader>ne` | Switch to export view |

### keymaps.views

| Key | Default | Description |
|-----|---------|-------------|
| `home` | `<leader>vh` | Show dashboard |
| `focus` | `<leader>vf` | Toggle focus mode |

### keymaps.writing

Buffer-level actions for prose files.

| Key | Default | Description |
|-----|---------|-------------|
| `notes` | `<leader>wn` | Open notes for current chapter/page |
| `marks` | `<leader>wm` | Browse marks in current buffer |
| `toggle_kind` | `<leader>wk` | Toggle chapter/page for current entry |
| `prose` | `<leader>ww` | Open prose for current chapter/page |

### keymaps.insert

| Key | Default | Description |
|-----|---------|-------------|
| `mark` | `<leader>im` | Insert a mark tag |
| `image` | `<leader>ii` | Insert an image |

### keymaps.snippets

| Key | Default | Mode | Description |
|-----|---------|------|-------------|
| `insert` | `<leader>si` | normal | Browse and insert snippets |
| `extract` | `<leader>sx` | visual | Cut selection to snippet |

### keymaps.misc

| Key | Default | Description |
|-----|---------|-------------|
| `clear_highlight` | `<Esc><Esc>` | Clear search highlight |

---

## ui

| Key | Default | Description |
|-----|---------|-------------|
| `mouse_mode` | `"single_click"` | Tree open behavior: `"single_click"` or `"double_click"` |

---

## editor

Settings applied to prose and notes buffers.

| Key | Default | Description |
|-----|---------|-------------|
| `textwidth` | `86` | Text width for formatting |
| `scrolloff` | `5` | Lines to keep above/below cursor |
| `tabstop` | `4` | Tab display width |
| `shiftwidth` | `4` | Indent width |
| `wrap` | `true` | Soft wrap long lines |
| `linebreak` | `true` | Wrap at word boundaries |
| `visual_line_navigation` | `true` | Map j/k to gj/gk |
| `autosave` | `false` | Auto-save on cursor hold and buffer leave |
| `focus_mode` | `true` | Enable focus mode by default |
| `termguicolors` | `true` | Enable 24-bit RGB colors (required for accurate theme colors in terminal) |

---

## finder

| Key | Default | Description |
|-----|---------|-------------|
| `preview` | `true` | Show file preview in picker |

---

## export

| Key | Default | Description |
|-----|---------|-------------|
| `auto_open` | `true` | Open exported file after successful export |

Use `--no-open` flag to skip auto-open for a single export: `:Export --no-open`

---

## neovide

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

---

## Navigator Keymaps

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
| `J` / `K` | Reorder down/up |
| `T` | Toggle chapter/page |

---

## Neovide Keymaps

These keymaps use macOS Cmd key and only work in Neovide. They are not configurable.

| Key | Action |
|-----|--------|
| `Cmd+S` | Save |
| `Cmd+C` | Copy (visual mode) |
| `Cmd+X` | Cut (visual mode) |
| `Cmd+V` | Paste |
| `Cmd+Shift+P` | Open command palette |
| `Cmd+Q` | Quit (built-in to Neovide) |
