-- Vimoire Nebula colorscheme
-- Cosmic dark theme with nebula purples, magentas, and starlight
-- Like writing among the stars, vast and infinite

local c = {
  -- Base tones (deep space blue-black)
  bg = "#0a0a14",
  bg_darker = "#06060e",
  bg_lighter = "#12121c",
  fg = "#d8d8e8",
  fg_dim = "#a0a0b8",
  fg_muted = "#505068",

  -- Prose elements (cosmic, expressive)
  header = "#b090d0",
  metadata = "#7090c0",
  todo = "#e0a060",
  scene_break = "#404058",
  dialogue = "#c0a0b0",
  italic = "#a0a8c0",

  -- UI accents
  cursor_line = "#101018",
  visual = "#1c1c2a",
  search_bg = "#2a2840",
  search_fg = "#e8e8f0",
  match = "#c0a0b0",

  -- Neotree structure (cosmic palette)
  book = "#d0b0e0",
  manuscript = "#a0b0d0",
  section = "#8090c0",
  chapter = "#9080b0",
  page = "#a090a8",
  planning = "#c09080",
  planning_item = "#d0a090",
  export = "#8888a8",
  export_folder = "#787898",
  export_file = "#9898b8",

  -- Statusline contexts
  status_prose = "#0a0a14",
  status_notes = "#0a0c16",
  status_planning = "#100a0e",
  status_export = "#0a0a12",

  -- Feedback
  error = "#c08090",
  warning = "#e0a060",
  info = "#8090c0",
  hint = "#9080b0",

  -- Spellcheck
  spell_bad = "#c08090",
  spell_cap = "#e0a060",
  spell_rare = "#7090c0",

  -- Comments
  comment_bg = "#1c1824",
  comment_sign = "#9080b0",

  -- Plotting
  plotting_header_bg = "#12121c",
  plotting_border = "#404058",
}

require("palette.apply")({
  name = "nebula",
  background = "dark",
  comment_sign = "✧",
  colors = c,
})
