-- Vimoire Vellum colorscheme
-- Sepia theme evoking aged manuscripts
-- Like writing on ancient parchment by candlelight

local c = {
  -- Base tones (parchment/sepia family)
  bg = "#f0e4d0",
  bg_darker = "#e8dcc6",
  bg_lighter = "#f8f0e0",
  fg = "#3d3428",
  fg_dim = "#5a4e40",
  fg_muted = "#8a7a68",

  -- Prose elements (earth tones)
  header = "#5a4030",
  metadata = "#6a5048",
  todo = "#7a5020",
  scene_break = "#c0b098",
  dialogue = "#7a4830",
  italic = "#585868",

  -- UI accents
  cursor_line = "#e8dcc8",
  visual = "#dcd0b8",
  search_bg = "#d8c8a0",
  search_fg = "#3d3428",
  match = "#7a5020",

  -- Neotree structure (earthy accents)
  book = "#6a4838",
  manuscript = "#5a4840",
  section = "#6a5a48",
  chapter = "#4a6050",
  page = "#5a6848",
  planning = "#7a4a3a",
  planning_item = "#5a3a2a",
  export = "#5a4858",
  export_folder = "#4a3848",
  export_file = "#6a5868",

  -- Statusline contexts
  status_prose = "#e8dcc6",
  status_notes = "#e0dcc8",
  status_planning = "#e8d8c0",
  status_export = "#e0d8c8",

  -- Feedback
  error = "#8a3030",
  warning = "#7a5020",
  info = "#4a5a60",
  hint = "#4a6050",

  -- Spellcheck
  spell_bad = "#8a3030",
  spell_cap = "#7a5020",
  spell_rare = "#6a5048",

  -- Comments
  comment_bg = "#e8dcc8",
  comment_sign = "#7a5020",

  -- Plotting
  plotting_header_bg = "#e8dcc6",
  plotting_border = "#c0b098",
}

require("palette.apply")({
  name = "vellum",
  background = "light",
  comment_sign = "✎",
  colors = c,
  overrides = {
    vimoireDialogue = { fg = c.dialogue, bold = true },
  },
})
