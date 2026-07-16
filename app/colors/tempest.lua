-- Vimoire Tempest colorscheme
-- Storm dark theme with steel grays and lightning accents
-- Like writing during a thunderstorm, dramatic flashes in the dark

local c = {
  -- Base tones (storm gray-blue)
  bg = "#101418",
  bg_darker = "#0a0c10",
  bg_lighter = "#181c22",
  fg = "#d4d8dc",
  fg_dim = "#9ca0a8",
  fg_muted = "#585c64",

  -- Prose elements (steel with warm lightning)
  header = "#b0b8c0",
  metadata = "#8898a8",
  todo = "#e8a048",
  scene_break = "#484c54",
  dialogue = "#c8c0a8",
  italic = "#a8b0b8",

  -- UI accents
  cursor_line = "#161a1e",
  visual = "#242830",
  search_bg = "#303840",
  search_fg = "#e0e4e8",
  match = "#e8a048",

  -- Neotree structure (storm palette)
  book = "#d0c8a0",
  manuscript = "#a8b0c0",
  section = "#8098b0",
  chapter = "#78a0a0",
  page = "#88a898",
  planning = "#b89070",
  planning_item = "#c8a080",
  export = "#8888a0",
  export_folder = "#787890",
  export_file = "#9898b0",

  -- Statusline contexts
  status_prose = "#101418",
  status_notes = "#10141a",
  status_planning = "#141210",
  status_export = "#101214",

  -- Feedback
  error = "#c08080",
  warning = "#e8a048",
  info = "#8098b0",
  hint = "#78a0a0",

  -- Spellcheck
  spell_bad = "#c08080",
  spell_cap = "#e8a048",
  spell_rare = "#8898a8",

  -- Comments
  comment_bg = "#1c2024",
  comment_sign = "#8098b0",

  -- Plotting
  plotting_header_bg = "#181c22",
  plotting_border = "#404854",
}

require("palette.apply")({
  name = "tempest",
  background = "dark",
  comment_sign = "⚡",
  colors = c,
})
