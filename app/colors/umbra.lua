-- Vimoire Umbra colorscheme
-- High contrast monochrome theme for pure focus
-- The darkest part of a shadow - nothing but you and the words

local c = {
  -- Base tones (near-monochrome, slight warmth)
  bg = "#0e0e0e",
  bg_darker = "#080808",
  bg_lighter = "#1a1a1a",
  fg = "#e4e0dc",
  fg_dim = "#b0aca8",
  fg_muted = "#606060",

  -- Prose elements (minimal, grayscale)
  header = "#d0d0d0",
  metadata = "#808080",
  todo = "#a0a0a0",
  scene_break = "#505050",

  -- UI accents
  cursor_line = "#1a1a1a",
  visual = "#2a2a2a",
  search_bg = "#3a3a3a",
  search_fg = "#e4e0dc",
  match = "#c0c0c0",

  -- Neotree structure (hierarchy through brightness only)
  book = "#e0e0e0",
  manuscript = "#d0d0d0",
  section = "#b0b0b0",
  chapter = "#a0a0a0",
  page = "#909090",
  planning = "#888888",
  planning_item = "#787878",
  export = "#989898",
  export_folder = "#888888",
  export_file = "#787878",

  -- Statusline contexts (brightness variations)
  status_prose = "#080808",
  status_notes = "#101010",
  status_planning = "#0c0c0c",
  status_export = "#0e0e0e",

  -- Feedback (subtle)
  error = "#c08080",
  warning = "#c0b080",
  info = "#8090a0",
  hint = "#80a090",

  -- Spellcheck
  spell_bad = "#c08080",
  spell_cap = "#c0b080",
  spell_rare = "#a090a0",

  -- Comments
  comment_bg = "#202020",
  comment_sign = "#909090",

  -- Plotting
  plotting_header_bg = "#1a1a1a",
  plotting_border = "#404040",
}

require("palette.apply")({
  name = "umbra",
  background = "dark",
  comment_sign = "●",
  colors = c,
  overrides = {
    -- Muted theme: accents recede to fg_dim, todo blocks stay flat.
    String = { fg = c.fg_dim },
    Statement = { fg = c.fg_dim },
    Function = { fg = c.fg_dim },
    Todo = { fg = c.bg, bg = c.todo },
    VimoireActionButton = { fg = c.bg_darker, bg = c.fg_dim, bold = true },
    VimoireStar = { fg = c.fg_dim },
    VimoireProjectSelected = { fg = c.fg, bold = true, underline = true },
    VimoireAction = { fg = c.fg_dim },
    VimoireKey = { fg = c.fg, bold = true },
    vimoireH4 = { fg = c.fg_dim },
    vimoireMetaTodo = { fg = c.fg, bg = c.bg_lighter },
    vimoireMetaTodoText = { fg = c.fg, bg = c.bg_lighter },
    vimoireBoldItalicStyle = { bold = true, italic = true },
    vimoireItalicStyle = { italic = true },
    vimoireDialogue = { fg = c.fg_dim },
  },
})
