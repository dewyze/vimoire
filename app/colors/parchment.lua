-- Vimoire Parchment colorscheme
-- Warm light theme for daytime writing
-- Like a writing desk by a window, morning light on paper

local c = {
  -- Base tones (warm cream family)
  bg = "#f8f4ee",
  bg_darker = "#f0ece4",
  bg_lighter = "#fffcf6",
  fg = "#3a3632",
  fg_dim = "#5a5652",
  fg_muted = "#8a8480",

  -- Prose elements
  header = "#4a6068",
  metadata = "#7a6488",
  todo = "#8a6030",
  scene_break = "#b0a090",
  dialogue = "#785840",
  italic = "#5a6470",

  -- UI accents
  cursor_line = "#f0ebe2",
  visual = "#e4ddd0",
  search_bg = "#e8d8b0",
  search_fg = "#3a3632",
  match = "#8a6030",

  -- Neotree structure (gentle accents)
  book = "#7a5a48",
  manuscript = "#6a5878",
  section = "#4a6a7a",
  chapter = "#3a7a6a",
  page = "#5a7a4a",
  planning = "#8a5a4a",
  planning_item = "#6a4a3a",
  export = "#5a5a78",
  export_folder = "#4a4a68",
  export_file = "#6a6a88",

  -- Statusline contexts
  status_prose = "#f0ece4",
  status_notes = "#e8eaee",
  status_planning = "#f0e8e4",
  status_export = "#eae8ee",

  -- Feedback
  error = "#a04040",
  warning = "#8a6030",
  info = "#4a6a7a",
  hint = "#3a7a6a",

  -- Spellcheck
  spell_bad = "#a04040",
  spell_cap = "#8a6030",
  spell_rare = "#7a6488",

  -- Comments
  comment_bg = "#ede6d8",
  comment_sign = "#8a6030",

  -- Plotting
  plotting_header_bg = "#f0ece4",
  plotting_border = "#c0b8a8",
}

require("palette.apply")({
  name = "parchment",
  background = "light",
  comment_sign = "✎",
  colors = c,
})
