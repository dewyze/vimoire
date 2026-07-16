-- Vimoire Inkwell colorscheme
-- Warm dark theme for evening writing sessions
-- Like writing by candlelight in a leather-bound study

local c = {
  -- Base tones (warm charcoal family)
  bg = "#1a1816",
  bg_darker = "#141210",
  bg_lighter = "#242220",
  fg = "#d8d4cc",
  fg_dim = "#a8a49c",
  fg_muted = "#6a6460",

  -- Prose elements
  header = "#c4a46a",
  metadata = "#a08cc0",
  todo = "#d4a054",
  scene_break = "#8a7060",
  dialogue = "#c8a868",
  italic = "#a8b0b8",

  -- UI accents
  cursor_line = "#262420",
  visual = "#3a3632",
  search_bg = "#5a4830",
  search_fg = "#f0e8d8",
  match = "#d4a054",

  -- Neotree structure (gentle accents)
  book = "#d4a888",
  manuscript = "#b89cd8",
  section = "#7a9aba",
  chapter = "#6aaa98",
  page = "#8aaa7a",
  planning = "#c08a6a",
  planning_item = "#d4a888",
  export = "#9a8aaa",
  export_folder = "#8a7a9a",
  export_file = "#a89ab8",

  -- Statusline contexts
  status_prose = "#1a1816",
  status_notes = "#1a1a20",
  status_planning = "#201816",
  status_export = "#1a1820",

  -- Feedback
  error = "#c07070",
  warning = "#c4a46a",
  info = "#7a9aba",
  hint = "#6aaa98",

  -- Spellcheck
  spell_bad = "#c07070",
  spell_cap = "#c4a46a",
  spell_rare = "#a08cc0",

  -- Comments
  comment_bg = "#2a2620",
  comment_sign = "#c4a46a",

  -- Plotting
  plotting_header_bg = "#2a2826",
  plotting_border = "#4a4640",
}

require("palette.apply")({
  name = "inkwell",
  background = "dark",
  comment_sign = "✎",
  colors = c,
})
