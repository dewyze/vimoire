-- Vimoire Umbra colorscheme
-- High contrast monochrome theme for pure focus
-- The darkest part of a shadow - nothing but you and the words

vim.cmd("hi clear")
vim.g.colors_name = "vimoire-umbra"
vim.o.background = "dark"

local c = {
  -- Base tones (near-monochrome, slight warmth)
  bg = "#0e0e0e",
  bg_darker = "#080808",
  bg_lighter = "#1a1a1a",
  fg = "#e4e0dc",
  fg_dim = "#b0aca8",
  fg_muted = "#606060",

  -- Prose elements (minimal, grayscale)
  header = "#d0d0d0",
  metadata = "#808080",
  todo = "#a0a0a0",
  scene_break = "#505050",

  -- UI accents
  cursor_line = "#1a1a1a",
  visual = "#2a2a2a",
  search_bg = "#3a3a3a",
  search_fg = "#e4e0dc",
  match = "#c0c0c0",

  -- Neotree structure (hierarchy through brightness only)
  book = "#e0e0e0",
  manuscript = "#d0d0d0",
  section = "#b0b0b0",
  chapter = "#a0a0a0",
  page = "#909090",
  planning = "#888888",
  planning_item = "#787878",
  export = "#989898",
  export_folder = "#888888",
  export_file = "#787878",

  -- Statusline contexts (brightness variations)
  status_prose = "#080808",
  status_notes = "#101010",
  status_planning = "#0c0c0c",
  status_export = "#0e0e0e",

  -- Feedback (subtle)
  error = "#c08080",
  warning = "#c0b080",
  info = "#8090a0",
  hint = "#80a090",

  -- Spellcheck
  spell_bad = "#c08080",
  spell_cap = "#c0b080",
  spell_rare = "#a090a0",
}

local hl = vim.api.nvim_set_hl

-- Base UI
hl(0, "Normal", { fg = c.fg, bg = c.bg })
hl(0, "NormalFloat", { fg = c.fg, bg = c.bg_darker })
hl(0, "FloatBorder", { fg = c.fg_muted })
hl(0, "Cursor", { fg = c.bg, bg = c.fg })
hl(0, "CursorLine", { bg = c.cursor_line })
hl(0, "CursorLineNr", { fg = c.fg })
hl(0, "LineNr", { fg = c.fg_muted })
hl(0, "SignColumn", { fg = c.fg_muted, bg = c.bg })
hl(0, "Visual", { bg = c.visual })
hl(0, "Search", { fg = c.search_fg, bg = c.search_bg })
hl(0, "IncSearch", { fg = c.bg, bg = c.match })
hl(0, "CurSearch", { fg = c.bg, bg = c.match })
hl(0, "Pmenu", { fg = c.fg, bg = c.bg_darker })
hl(0, "PmenuSel", { fg = c.bg, bg = c.fg_dim })
hl(0, "StatusLine", { fg = c.fg_dim, bg = c.bg_darker })
hl(0, "StatusLineNC", { fg = c.fg_muted, bg = c.bg_darker })
hl(0, "WinBar", { fg = c.fg, bold = true })
hl(0, "WinBarNC", { fg = c.fg_muted })
hl(0, "VertSplit", { fg = c.bg_lighter })
hl(0, "WinSeparator", { fg = c.bg_lighter })
hl(0, "NonText", { fg = c.fg_muted })
hl(0, "MatchParen", { fg = c.match, bold = true })
hl(0, "ErrorMsg", { fg = c.error })
hl(0, "WarningMsg", { fg = c.warning })
hl(0, "ModeMsg", { fg = c.fg_dim })
hl(0, "MoreMsg", { fg = c.info })
hl(0, "Question", { fg = c.info })

-- Standard highlight groups (for fallback links)
hl(0, "Title", { fg = c.header, bold = true })
hl(0, "Comment", { fg = c.fg_muted, italic = true })
hl(0, "Special", { fg = c.metadata })
hl(0, "Identifier", { fg = c.fg })
hl(0, "Directory", { fg = c.section })
hl(0, "String", { fg = c.fg_dim })
hl(0, "Statement", { fg = c.fg_dim })
hl(0, "Function", { fg = c.fg_dim })
hl(0, "Todo", { fg = c.bg, bg = c.todo })

-- Diagnostics
hl(0, "DiagnosticError", { fg = c.error })
hl(0, "DiagnosticWarn", { fg = c.warning })
hl(0, "DiagnosticInfo", { fg = c.info })
hl(0, "DiagnosticHint", { fg = c.hint })

-- Spelling
hl(0, "SpellBad", { undercurl = true, sp = c.spell_bad })
hl(0, "SpellCap", { undercurl = true, sp = c.spell_cap })
hl(0, "SpellLocal", { undercurl = true, sp = c.info })
hl(0, "SpellRare", { undercurl = true, sp = c.spell_rare })

-- Neo-tree
hl(0, "NeoTreeNormal", { fg = c.fg, bg = c.bg_darker })
hl(0, "NeoTreeNormalNC", { fg = c.fg, bg = c.bg_darker })
hl(0, "NeoTreeEndOfBuffer", { fg = c.bg_darker, bg = c.bg_darker })
hl(0, "NeoTreeCursorLine", { bg = c.cursor_line })
hl(0, "NeoTreeTitleBar", { fg = c.bg_darker, bg = c.fg_dim, bold = true })
hl(0, "NeoTreeFloatBorder", { fg = c.fg_muted })
hl(0, "NeoTreeFloatTitle", { fg = c.header, bold = true })

-- Vimoire Navigator (brightness hierarchy, no color)
hl(0, "VimoireBook", { fg = c.book, bold = true })
hl(0, "VimoireManuscript", { fg = c.manuscript, bold = true })
hl(0, "VimoireSection", { fg = c.section, bold = true })
hl(0, "VimoireChapter", { fg = c.chapter })
hl(0, "VimoirePage", { fg = c.page })
hl(0, "VimoirePlanning", { fg = c.planning, bold = true })
hl(0, "VimoirePlanningSubfolder", { fg = c.planning, bold = true })
hl(0, "VimoirePlanningItem", { fg = c.planning_item })
hl(0, "VimoireExport", { fg = c.export, bold = true })
hl(0, "VimoireExportFolder", { fg = c.export_folder, bold = true })
hl(0, "VimoireExportFile", { fg = c.export_file })
hl(0, "VimoireActionButton", { fg = c.bg_darker, bg = c.fg_dim, bold = true })
hl(0, "VimoireWinbar", { fg = c.fg, bold = true })

-- Vimoire Start Screen
hl(0, "VimoireLogo", { fg = c.header, bold = true })
hl(0, "VimoireLogoGlow", { fg = c.bg_lighter })
hl(0, "VimoireTagline", { fg = c.fg_muted, italic = true })
hl(0, "VimoireStar", { fg = c.fg_dim })
hl(0, "VimoireHeader", { fg = c.header, bold = true })
hl(0, "VimoireProject", { fg = c.fg })
hl(0, "VimoireProjectSelected", { fg = c.fg, bold = true, underline = true })
hl(0, "VimoirePath", { fg = c.fg_muted })
hl(0, "VimoireDate", { fg = c.fg_muted })
hl(0, "VimoireAction", { fg = c.fg_dim })
hl(0, "VimoireKey", { fg = c.fg, bold = true })

-- Vimoire Prose (minimal, text-focused)
hl(0, "vimoireH1", { fg = c.header, bold = true })
hl(0, "vimoireH2", { fg = c.header, bold = true })
hl(0, "vimoireH3", { fg = c.header })
hl(0, "vimoireH4", { fg = c.fg_dim })
hl(0, "vimoireH5", { fg = c.fg_dim })
hl(0, "vimoireH6", { fg = c.fg_dim })
hl(0, "vimoireSceneBreak", { fg = c.scene_break })
hl(0, "vimoireBlockQuote", { fg = c.fg_dim, italic = true })
hl(0, "vimoireFencedDiv", { fg = c.fg_muted })
hl(0, "vimoireMetaChapter", { fg = c.metadata })
hl(0, "vimoireMetaMark", { fg = c.metadata })
hl(0, "vimoireMetaMarkText", { fg = c.metadata })
hl(0, "vimoireMetaTodo", { fg = c.fg, bg = c.bg_lighter })
hl(0, "vimoireMetaTodoText", { fg = c.fg, bg = c.bg_lighter })

-- Inline formatting (inherit fg, just add attributes)
hl(0, "vimoireBoldItalicStyle", { bold = true, italic = true })
hl(0, "vimoireBoldStyle", { bold = true })
hl(0, "vimoireItalicStyle", { italic = true })
hl(0, "vimoireUnderlineStyle", { underline = true })

-- Statusline (brightness variations for context)
hl(0, "VimoireStatusProse", { fg = c.fg_dim, bg = c.status_prose })
hl(0, "VimoireStatusNotes", { fg = c.section, bg = c.status_notes })
hl(0, "VimoireStatusPlanning", { fg = c.planning, bg = c.status_planning })
hl(0, "VimoireStatusExport", { fg = c.export, bg = c.status_export })
