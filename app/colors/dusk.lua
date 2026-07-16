-- Vimoire Dusk colorscheme
-- Twilight dark theme with dusty roses and violet
-- Like writing as the evening star appears, day yielding to night

local c = {
  -- Base tones (purple-black twilight)
  bg = "#14101a",
  bg_darker = "#0e0a12",
  bg_lighter = "#1c1624",
  fg = "#d8d4dc",
  fg_dim = "#a8a4b0",
  fg_muted = "#605868",

  -- Prose elements (romantic, expressive)
  header = "#c0a0b8",
  metadata = "#a090c0",
  todo = "#d8a060",
  scene_break = "#584858",
  dialogue = "#d0b0a8",
  italic = "#b0a8c0",

  -- UI accents
  cursor_line = "#1a1420",
  visual = "#2a2234",
  search_bg = "#3a2840",
  search_fg = "#e8e0ec",
  match = "#d0b0a8",

  -- Neotree structure (twilight palette)
  book = "#d0a8b0",
  manuscript = "#b0a0c8",
  section = "#9090b8",
  chapter = "#a088a8",
  page = "#b898a0",
  planning = "#c89080",
  planning_item = "#d8a090",
  export = "#9888a0",
  export_folder = "#887898",
  export_file = "#a898b0",

  -- Statusline contexts
  status_prose = "#14101a",
  status_notes = "#14121c",
  status_planning = "#181014",
  status_export = "#141018",

  -- Feedback
  error = "#c08088",
  warning = "#d8a060",
  info = "#9090b8",
  hint = "#a088a8",

  -- Spellcheck
  spell_bad = "#c08088",
  spell_cap = "#d8a060",
  spell_rare = "#a090c0",

  -- Comments
  comment_bg = "#201c24",
  comment_sign = "#a088b8",

  -- Plotting
  plotting_header_bg = "#1c1624",
  plotting_border = "#483858",
}

require("palette.apply")({
  name = "dusk",
  background = "dark",
  comment_sign = "☽",
  colors = c,
})
