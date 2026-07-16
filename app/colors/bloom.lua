-- Vimoire Bloom colorscheme
-- Soft rose and blush light theme
-- Like writing at a garden table in early spring

local c = {
  -- Base tones (very faint blush family)
  bg = "#faf3f3",
  bg_darker = "#f2e8e8",
  bg_lighter = "#fdf9f9",
  fg = "#38282c",
  fg_dim = "#584048",
  fg_muted = "#9a7880",

  -- Prose elements
  header = "#5a3848",
  metadata = "#786880",
  todo = "#784050",
  scene_break = "#c8b0b8",
  dialogue = "#7a1838",
  italic = "#485870",

  -- UI accents
  cursor_line = "#f2e6e8",
  visual = "#eadcde",
  search_bg = "#e8c8d0",
  search_fg = "#38282c",
  match = "#784050",

  -- Neotree structure (rose + contrasting hues)
  book = "#7a1838",
  manuscript = "#8a2858",
  section = "#6a3880",
  chapter = "#2a6080",
  page = "#3a7850",
  planning = "#903050",
  planning_item = "#702040",
  export = "#505890",
  export_folder = "#404080",
  export_file = "#6068a8",

  -- Statusline contexts
  status_prose = "#f2e8e8",
  status_notes = "#e8e6ec",
  status_planning = "#f0e4e8",
  status_export = "#e8e4f0",

  -- Feedback
  error = "#9a3040",
  warning = "#784050",
  info = "#485870",
  hint = "#486858",

  -- Spellcheck
  spell_bad = "#9a3040",
  spell_cap = "#784050",
  spell_rare = "#786880",

  -- Comments
  comment_bg = "#eee0e2",
  comment_sign = "#784050",

  -- Plotting
  plotting_header_bg = "#f2e8e8",
  plotting_border = "#c8b0b8",
}

require("palette.apply")({
  name = "bloom",
  background = "light",
  comment_sign = "❧",
  colors = c,
})
