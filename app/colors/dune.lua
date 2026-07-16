-- Vimoire Dune colorscheme
-- Warm sandy desert light theme
-- Golden noon light on open sand — and the spice is everywhere

local c = {
  -- Base tones (warm sandy gold family)
  bg = "#f7f1e2",
  bg_darker = "#efe8d2",
  bg_lighter = "#fdf9ef",
  fg = "#3a3020",
  fg_dim = "#5a5038",
  fg_muted = "#9a8868",

  -- Prose elements
  header = "#6a5020",
  metadata = "#2a5888", -- the spice — blue eyes of ibad
  todo = "#8a6018",
  scene_break = "#c8b880",
  dialogue = "#2a5888",
  italic = "#2a5888", -- the spice flows through every word

  -- UI accents
  cursor_line = "#efe8d0",
  visual = "#e8dcc0",
  search_bg = "#e8d898",
  search_fg = "#3a3020",
  match = "#8a6018",

  -- Neotree structure (desert ochres, spice blue on manuscript + export)
  book = "#7a4010",
  manuscript = "#2a5888", -- the spice — most precious thing in the world
  section = "#8a6010",
  chapter = "#7a4808",
  page = "#5a7030",
  planning = "#9a4828",
  planning_item = "#783820",
  export = "#2a5888", -- the spice flows outward too
  export_folder = "#1a4070",
  export_file = "#3a6898",

  -- Statusline contexts
  status_prose = "#efe8d2",
  status_notes = "#e8e8d0",
  status_planning = "#f0e4c0",
  status_export = "#e0e8e8",

  -- Feedback
  error = "#9a3030",
  warning = "#8a6018",
  info = "#3a5878",
  hint = "#4a6888",

  -- Spellcheck
  spell_bad = "#9a3030",
  spell_cap = "#8a6018",
  spell_rare = "#3a6080",

  -- Comments
  comment_bg = "#ece0c0",
  comment_sign = "#8a6018",

  -- Plotting
  plotting_header_bg = "#efe8d2",
  plotting_border = "#c8b880",
}

require("palette.apply")({
  name = "dune",
  background = "light",
  comment_sign = "✦",
  colors = c,
})
