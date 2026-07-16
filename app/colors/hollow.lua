-- Vimoire Hollow colorscheme
-- Forest dark theme with natural, earthy tones
-- Like writing in a woodland cabin, moss and amber light

local c = {
  -- Base tones (forest black with green undertone)
  bg = "#0f1410",
  bg_darker = "#0a0e0b",
  bg_lighter = "#181f18",
  fg = "#d0d4c8",
  fg_dim = "#a0a498",
  fg_muted = "#5a6058",

  -- Prose elements (natural, sparing)
  header = "#b8a878",
  metadata = "#88a088",
  todo = "#d0a048",
  scene_break = "#505848",
  dialogue = "#c8b078",
  italic = "#98a8a0",

  -- UI accents
  cursor_line = "#161c16",
  visual = "#242c24",
  search_bg = "#3a4030",
  search_fg = "#e0e4d8",
  match = "#c8b078",

  -- Neotree structure (forest palette)
  book = "#d0b080",
  manuscript = "#a8c0a0",
  section = "#80a080",
  chapter = "#90b078",
  page = "#a0a870",
  planning = "#c09060",
  planning_item = "#d0a070",
  export = "#909078",
  export_folder = "#808068",
  export_file = "#a0a088",

  -- Statusline contexts
  status_prose = "#0f1410",
  status_notes = "#101412",
  status_planning = "#14120f",
  status_export = "#101210",

  -- Feedback
  error = "#c08070",
  warning = "#d0a048",
  info = "#80a080",
  hint = "#90b078",

  -- Spellcheck
  spell_bad = "#c08070",
  spell_cap = "#d0a048",
  spell_rare = "#88a088",

  -- Comments
  comment_bg = "#1c241c",
  comment_sign = "#90b078",

  -- Plotting
  plotting_header_bg = "#181f18",
  plotting_border = "#404840",
}

require("palette.apply")({
  name = "hollow",
  background = "dark",
  comment_sign = "❧",
  colors = c,
})
