-- Vimoire Lumen colorscheme
-- High contrast monochrome light theme for pure focus
-- The brightest clarity - nothing but you and the words

local c = {
  -- Base tones (near-white, slight warmth to reduce harshness)
  bg = "#f6f4f2",
  bg_darker = "#eceae8",
  bg_lighter = "#fdfcfb",
  fg = "#1a1a1a",
  fg_dim = "#4a4a4a",
  fg_muted = "#909090",

  -- Prose elements (minimal, grayscale)
  header = "#2a2a2a",
  metadata = "#707070",
  todo = "#505050",
  scene_break = "#c0c0c0",

  -- UI accents
  cursor_line = "#eceae6",
  visual = "#dddbd8",
  search_bg = "#d0cec8",
  search_fg = "#1a1a1a",
  match = "#3a3a3a",

  -- Neotree structure (hierarchy through brightness only)
  book = "#0a0a0a",
  manuscript = "#1a1a1a",
  section = "#3a3a3a",
  chapter = "#4a4a4a",
  page = "#5a5a5a",
  planning = "#606060",
  planning_item = "#707070",
  export = "#505050",
  export_folder = "#606060",
  export_file = "#707070",

  -- Statusline contexts (brightness variations)
  status_prose = "#eceae8",
  status_notes = "#e4e4e6",
  status_planning = "#e8e6e4",
  status_export = "#e6e4e8",

  -- Feedback (subtle)
  error = "#8a4040",
  warning = "#6a5030",
  info = "#405060",
  hint = "#406050",

  -- Spellcheck
  spell_bad = "#8a4040",
  spell_cap = "#6a5030",
  spell_rare = "#605060",

  -- Comments
  comment_bg = "#e0e0e0",
  comment_sign = "#606060",

  -- Plotting
  plotting_header_bg = "#eceae8",
  plotting_border = "#c0c0c0",
}

require("palette.apply")({
  name = "lumen",
  background = "light",
  comment_sign = "●",
  colors = c,
  overrides = {
    -- Muted theme: accents recede to fg_dim, decorations drop bold/color.
    String = { fg = c.fg_dim },
    Statement = { fg = c.fg_dim },
    Function = { fg = c.fg_dim },
    Todo = { fg = c.bg, bg = c.todo },
    VimoireActionButton = { fg = c.bg_lighter, bg = c.fg_dim, bold = true },
    VimoireStar = { fg = c.fg_dim },
    VimoireProjectSelected = { fg = c.fg, bold = true, underline = true },
    VimoireAction = { fg = c.fg_dim },
    VimoireKey = { fg = c.fg, bold = true },
    vimoireH4 = { fg = c.fg_dim },
    vimoireBoldItalicStyle = { bold = true, italic = true },
    vimoireItalicStyle = { italic = true },
    vimoireDialogue = { fg = c.fg_dim },
    cssProp = { fg = c.fg_dim },
    cssAttr = { fg = c.fg_dim },
    cssColor = { fg = c.fg_dim },
    cssValueLength = { fg = c.fg_dim },
    cssValueNumber = { fg = c.fg_dim },
  },
})
