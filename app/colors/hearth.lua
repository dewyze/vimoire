-- Vimoire Hearth colorscheme
-- Firelight dark theme with warm reds, oranges, and golds
-- Like writing by a dying fire, embers glowing in the dark

local c = {
  -- Base tones (warm black with red undertone)
  bg = "#151010",
  bg_darker = "#0e0a0a",
  bg_lighter = "#1e1616",
  fg = "#e0d8d0",
  fg_dim = "#b0a898",
  fg_muted = "#685850",

  -- Prose elements (fire and ember)
  header = "#d89860",
  metadata = "#c08070",
  todo = "#e8a040",
  scene_break = "#584038",
  dialogue = "#d8a868",
  italic = "#c0a890",

  -- UI accents
  cursor_line = "#1c1414",
  visual = "#2c2020",
  search_bg = "#3c2820",
  search_fg = "#f0e8e0",
  match = "#e8a040",

  -- Neotree structure (fire palette)
  book = "#e8b878",
  manuscript = "#d09070",
  section = "#c08060",
  chapter = "#b89060",
  page = "#a89070",
  planning = "#c07050",
  planning_item = "#d08060",
  export = "#a08070",
  export_folder = "#907060",
  export_file = "#b09080",

  -- Statusline contexts
  status_prose = "#151010",
  status_notes = "#151012",
  status_planning = "#181010",
  status_export = "#141012",

  -- Feedback
  error = "#d07060",
  warning = "#e8a040",
  info = "#a08878",
  hint = "#b89060",

  -- Spellcheck
  spell_bad = "#d07060",
  spell_cap = "#e8a040",
  spell_rare = "#c08070",

  -- Comments
  comment_bg = "#241c18",
  comment_sign = "#d08050",

  -- Plotting
  plotting_header_bg = "#1e1616",
  plotting_border = "#504038",
}

require("palette.apply")({
  name = "hearth",
  background = "dark",
  comment_sign = "⁂",
  colors = c,
})
