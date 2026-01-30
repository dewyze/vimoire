-- Vimoire Hollow colorscheme
-- Forest dark theme with natural, earthy tones
-- Like writing in a woodland cabin, moss and amber light

vim.cmd("hi clear")
vim.g.colors_name = "hollow"
vim.o.background = "dark"

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
hl(0, "String", { fg = c.page })
hl(0, "Statement", { fg = c.section })
hl(0, "Function", { fg = c.chapter })
hl(0, "Todo", { fg = c.bg, bg = c.todo, bold = true })

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

-- Vimoire Navigator (forest accents)
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
hl(0, "VimoireActionButton", { fg = c.bg_darker, bg = c.export, bold = true })
hl(0, "VimoireWinbar", { fg = c.fg, bold = true })

-- Vimoire Start Screen
hl(0, "VimoireLogo", { fg = c.header, bold = true })
hl(0, "VimoireLogoGlow", { fg = c.bg_lighter })
hl(0, "VimoireTagline", { fg = c.fg_muted, italic = true })
hl(0, "VimoireStar", { fg = c.metadata })
hl(0, "VimoireHeader", { fg = c.header, bold = true })
hl(0, "VimoireProject", { fg = c.fg })
hl(0, "VimoireProjectSelected", { fg = c.match, bold = true })
hl(0, "VimoirePath", { fg = c.fg_muted })
hl(0, "VimoireDate", { fg = c.fg_muted })
hl(0, "VimoireAction", { fg = c.chapter })
hl(0, "VimoireKey", { fg = c.todo, bold = true })

-- Vimoire Prose (natural tones, sparing color)
hl(0, "vimoireH1", { fg = c.header, bold = true })
hl(0, "vimoireH2", { fg = c.header, bold = true })
hl(0, "vimoireH3", { fg = c.header })
hl(0, "vimoireH4", { fg = c.header })
hl(0, "vimoireH5", { fg = c.fg_dim })
hl(0, "vimoireH6", { fg = c.fg_dim })
hl(0, "vimoireSceneBreak", { fg = c.scene_break })
hl(0, "vimoireBlockQuote", { fg = c.fg_dim, italic = true })
hl(0, "vimoireFencedDiv", { fg = c.fg_muted })
hl(0, "vimoireMetaChapter", { fg = c.metadata })
hl(0, "vimoireMetaMark", { fg = c.metadata })
hl(0, "vimoireMetaMarkText", { fg = c.metadata })
hl(0, "vimoireMetaTodo", { fg = c.bg, bg = c.todo })
hl(0, "vimoireMetaTodoText", { fg = c.bg, bg = c.todo })

-- Inline formatting (earthy tints)
hl(0, "vimoireBoldItalicStyle", { fg = c.italic, bold = true, italic = true })
hl(0, "vimoireBoldStyle", { bold = true })
hl(0, "vimoireItalicStyle", { fg = c.italic, italic = true })
hl(0, "vimoireUnderlineStyle", { underline = true })
hl(0, "vimoireDialogue", { fg = c.dialogue })

-- Statusline (context-colored backgrounds)
hl(0, "VimoireStatusProse", { fg = c.fg_dim, bg = c.status_prose })
hl(0, "VimoireStatusNotes", { fg = c.section, bg = c.status_notes })
hl(0, "VimoireStatusPlanning", { fg = c.planning, bg = c.status_planning })
hl(0, "VimoireStatusExport", { fg = c.export, bg = c.status_export })

-- Snacks picker (match Normal background, not NormalFloat)
hl(0, "SnacksPickerList", { fg = c.fg, bg = c.bg })
hl(0, "SnacksPickerListCursorLine", { bg = c.cursor_line })

-- Comments
hl(0, "VimoireComment", { bg = c.comment_bg })
hl(0, "VimoireCommentSign", { fg = c.comment_sign })
vim.g.vimoire_comment_sign = "❧"

-- Plotting boards
hl(0, "VimoirePlottingHeader", { fg = c.header, bg = c.plotting_header_bg, bold = true })
hl(0, "VimoirePlottingBorder", { fg = c.plotting_border })

-- CSS (for epub.css readability)
hl(0, "cssProp", { fg = c.chapter })
hl(0, "cssAttr", { fg = c.chapter })
hl(0, "cssClassName", { fg = c.header })
hl(0, "cssClassNameDot", { fg = c.header })
hl(0, "cssIdentifier", { fg = c.header })
hl(0, "cssTagName", { fg = c.section })
hl(0, "cssColor", { fg = c.page })
hl(0, "cssValueLength", { fg = c.page })
hl(0, "cssValueNumber", { fg = c.page })
hl(0, "cssUnitDecorators", { fg = c.fg_muted })
