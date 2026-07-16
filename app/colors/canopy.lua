-- Vimoire Canopy colorscheme
-- Soft sage green light theme
-- Like writing at a table under the trees, dappled light through leaves

local c = {
  -- Base tones (very light sage family)
  bg = "#f2f5f0",
  bg_darker = "#e6ece2",
  bg_lighter = "#f8fbf6",
  fg = "#283428",
  fg_dim = "#485848",
  fg_muted = "#7a907a",

  -- Prose elements
  header = "#3a5438",
  metadata = "#58706a",
  todo = "#4a6840",
  scene_break = "#a8c0a0",
  dialogue = "#156648",
  italic = "#485870",

  -- UI accents
  cursor_line = "#e6ece2",
  visual = "#d8e4d4",
  search_bg = "#c0d8b8",
  search_fg = "#283428",
  match = "#4a6840",

  -- Neotree structure (distinct hues on sage bg)
  book = "#1a4828",
  manuscript = "#2a7040",
  section = "#1a7068",
  chapter = "#107858",
  page = "#3a7828",
  planning = "#8a5030",
  planning_item = "#6a3818",
  export = "#384878",
  export_folder = "#283068",
  export_file = "#485888",

  -- Statusline contexts
  status_prose = "#e6ece2",
  status_notes = "#dce8dc",
  status_planning = "#e6ead8",
  status_export = "#dce4e8",

  -- Feedback
  error = "#883838",
  warning = "#786040",
  info = "#384860",
  hint = "#3a6858",

  -- Spellcheck
  spell_bad = "#883838",
  spell_cap = "#786040",
  spell_rare = "#58706a",

  -- Comments
  comment_bg = "#d8e8d4",
  comment_sign = "#4a6840",

  -- Plotting
  plotting_header_bg = "#e6ece2",
  plotting_border = "#a8c0a0",
}

require("palette.apply")({
  name = "canopy",
  background = "light",
  comment_sign = "✾",
  colors = c,
})
