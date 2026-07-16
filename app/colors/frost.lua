-- Frost colorscheme
-- Arctic dark theme with icy blues and crisp whites
-- Like writing in a frozen library, breath visible in the air

local c = {
  -- Base tones (cold blue-black)
  bg = "#0a0e14",
  bg_darker = "#060a0f",
  bg_lighter = "#121820",
  fg = "#d8e0e8",
  fg_dim = "#a0b0c0",
  fg_muted = "#506070",

  -- Prose elements (icy, crisp)
  header = "#90c0e0",
  metadata = "#80a0b8",
  todo = "#e0c080",
  scene_break = "#405060",
  dialogue = "#b0d0e8",
  italic = "#a0c0d0",

  -- UI accents
  cursor_line = "#101820",
  visual = "#1a2830",
  search_bg = "#203040",
  search_fg = "#e8f0f8",
  match = "#90c0e0",

  -- Neotree structure (frost palette)
  book = "#e0e8f0",
  manuscript = "#b0d0e8",
  section = "#80b0d0",
  chapter = "#70a8c8",
  page = "#90b8c8",
  planning = "#c0a080",
  planning_item = "#d0b090",
  export = "#8090a8",
  export_folder = "#708098",
  export_file = "#90a0b8",

  -- Statusline contexts
  status_prose = "#0a0e14",
  status_notes = "#0a1018",
  status_planning = "#100e0a",
  status_export = "#0a0c12",

  -- Feedback
  error = "#c08090",
  warning = "#e0c080",
  info = "#80b0d0",
  hint = "#70a8c8",

  -- Spellcheck
  spell_bad = "#c08090",
  spell_cap = "#e0c080",
  spell_rare = "#80a0b8",

  -- Comments
  comment_bg = "#141820",
  comment_sign = "#80b0d0",

  -- Plotting
  plotting_header_bg = "#121820",
  plotting_border = "#405060",
}

require("palette.apply")({
  name = "frost",
  background = "dark",
  comment_sign = "❄",
  colors = c,
})
