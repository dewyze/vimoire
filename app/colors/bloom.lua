-- Vimoire Bloom colorscheme
-- Soft rose and blush light theme
-- Like writing at a garden table in early spring

vim.cmd("hi clear")
vim.g.colors_name = "bloom"
vim.o.background = "light"

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

local hl = vim.api.nvim_set_hl

-- Base UI
hl(0, "Normal", { fg = c.fg, bg = c.bg })
hl(0, "NormalFloat", { fg = c.fg, bg = c.bg_lighter })
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
hl(0, "VertSplit", { fg = c.bg_darker })
hl(0, "WinSeparator", { fg = c.bg_darker })
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
hl(0, "NeoTreeTitleBar", { fg = c.bg_lighter, bg = c.fg_dim, bold = true })
hl(0, "NeoTreeFloatBorder", { fg = c.fg_muted })
hl(0, "NeoTreeFloatTitle", { fg = c.header, bold = true })

-- Vimoire Navigator (dusty rose accents)
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
hl(0, "VimoireActionButton", { fg = c.bg_lighter, bg = c.export, bold = true })
hl(0, "VimoireWinbar", { fg = c.fg, bold = true })

-- Vimoire Start Screen
hl(0, "VimoireLogo", { fg = c.header, bold = true })
hl(0, "VimoireLogoGlow", { fg = c.bg_darker })
hl(0, "VimoireTagline", { fg = c.fg_muted, italic = true })
hl(0, "VimoireStar", { fg = c.metadata })
hl(0, "VimoireHeader", { fg = c.header, bold = true })
hl(0, "VimoireProject", { fg = c.fg })
hl(0, "VimoireProjectSelected", { fg = c.match, bold = true })
hl(0, "VimoirePath", { fg = c.fg_muted })
hl(0, "VimoireDate", { fg = c.fg_muted })
hl(0, "VimoireAction", { fg = c.chapter })
hl(0, "VimoireKey", { fg = c.todo, bold = true })

-- Vimoire Prose (body text inherits Normal, markers subtle)
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

-- Inline formatting
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
