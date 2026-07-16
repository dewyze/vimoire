-- Vimoire Mist colorscheme
-- Cool blue-grey light theme
-- Like writing on an overcast morning, fog on the window

local c = {
  -- Base tones (cool blue-grey family)
  bg = "#f2f4f7",
  bg_darker = "#e6eaef",
  bg_lighter = "#f8fafc",
  fg = "#2a3240",
  fg_dim = "#4a5568",
  fg_muted = "#8090a8",

  -- Prose elements
  header = "#365878",
  metadata = "#6070a0",
  todo = "#406880",
  scene_break = "#a8b8cc",
  dialogue = "#1a7080",
  italic = "#4a5878",

  -- UI accents
  cursor_line = "#eaecf2",
  visual = "#d8e0ea",
  search_bg = "#c0d0e4",
  search_fg = "#2a3240",
  match = "#3a6080",

  -- Neotree structure (distinct hues on cool bg)
  book = "#2a3858",
  manuscript = "#6050a0",
  section = "#3a6888",
  chapter = "#2a8878",
  page = "#4a8868",
  planning = "#8a5040",
  planning_item = "#6a3828",
  export = "#505898",
  export_folder = "#404888",
  export_file = "#6068b0",

  -- Statusline contexts
  status_prose = "#e6eaef",
  status_notes = "#dce6f0",
  status_planning = "#e4dff0",
  status_export = "#dce8f0",

  -- Feedback
  error = "#8a3040",
  warning = "#706040",
  info = "#365878",
  hint = "#306878",

  -- Spellcheck
  spell_bad = "#8a3040",
  spell_cap = "#706040",
  spell_rare = "#6070a0",

  -- Comments
  comment_bg = "#d8e4f0",
  comment_sign = "#3a6080",

  -- Plotting
  plotting_header_bg = "#e6eaef",
  plotting_border = "#b0c0d4",
}

require("palette.apply")({
  name = "mist",
  background = "light",
  comment_sign = "◈",
  colors = c,
})
