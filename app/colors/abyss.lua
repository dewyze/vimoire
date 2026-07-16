-- Vimoire Abyss colorscheme
-- Cool oceanic dark theme with bioluminescent accents
-- Like writing in a lighthouse, deep water and silver light

local c = {
  -- Base tones (deep ocean blue-black)
  bg = "#0d1117",
  bg_darker = "#080c10",
  bg_lighter = "#151d26",
  fg = "#c8d4e0",
  fg_dim = "#8a9aac",
  fg_muted = "#4a5a6c",

  -- Prose elements (cool with warm accents)
  header = "#7ab0d0",
  metadata = "#9a8ac0",
  todo = "#e0a050",
  scene_break = "#4a6070",
  dialogue = "#70b8b0",
  italic = "#a0b8c8",

  -- UI accents
  cursor_line = "#151c24",
  visual = "#1e2a38",
  search_bg = "#2a4050",
  search_fg = "#e0e8f0",
  match = "#70b8b0",

  -- Neotree structure (oceanic palette)
  book = "#e0d0a0",
  manuscript = "#a0c0d8",
  section = "#70a0c0",
  chapter = "#60b0a0",
  page = "#80b890",
  planning = "#c0a080",
  planning_item = "#d0b898",
  export = "#8090b0",
  export_folder = "#7080a0",
  export_file = "#90a0c0",

  -- Statusline contexts
  status_prose = "#0d1117",
  status_notes = "#0d1318",
  status_planning = "#12110d",
  status_export = "#0d0f14",

  -- Feedback
  error = "#c07080",
  warning = "#d0a050",
  info = "#70a0c0",
  hint = "#60b0a0",

  -- Spellcheck
  spell_bad = "#c07080",
  spell_cap = "#d0a050",
  spell_rare = "#9a8ac0",

  -- Comments
  comment_bg = "#141c24",
  comment_sign = "#70a0c0",

  -- Plotting
  plotting_header_bg = "#151d26",
  plotting_border = "#3a4858",
}

require("palette.apply")({
  name = "abyss",
  background = "dark",
  comment_sign = "≋",
  colors = c,
})
