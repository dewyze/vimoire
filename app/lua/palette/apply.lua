-- Palette engine: maps a theme's palette onto vimoire's highlight groups.
--
-- A theme is a table: {
--   name         = "abyss",         -- colors_name
--   background   = "dark"|"light",
--   comment_sign = "≋",             -- gutter glyph for comment threads
--   colors       = { ... },         -- the palette (bg, fg, header, ...)
--   overrides    = { Group = spec } -- optional; wins over the shared mapping
-- }
--
-- Elevation is background-relative: on a dark theme an "elevated" surface
-- (floats, buttons) goes darker and a "subtle" line goes lighter; on a light
-- theme both invert. Encoding that here keeps every palette a pure color
-- table and the light/dark rule stated once.

local hl = vim.api.nvim_set_hl

local function apply(theme)
  vim.cmd("hi clear")
  vim.g.colors_name = theme.name
  vim.o.background = theme.background
  vim.g.vimoire_comment_sign = theme.comment_sign

  local c = theme.colors
  local dark = theme.background == "dark"
  local elevated = dark and c.bg_darker or c.bg_lighter
  local subtle = dark and c.bg_lighter or c.bg_darker

  local groups = {
    -- Base UI
    Normal = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = elevated },
    FloatBorder = { fg = c.fg_muted },
    Cursor = { fg = c.bg, bg = c.fg },
    CursorLine = { bg = c.cursor_line },
    CursorLineNr = { fg = c.fg },
    LineNr = { fg = c.fg_muted },
    SignColumn = { fg = c.fg_muted, bg = c.bg },
    Visual = { bg = c.visual },
    Search = { fg = c.search_fg, bg = c.search_bg },
    IncSearch = { fg = c.bg, bg = c.match },
    CurSearch = { fg = c.bg, bg = c.match },
    Pmenu = { fg = c.fg, bg = c.bg_darker },
    PmenuSel = { fg = c.bg, bg = c.fg_dim },
    StatusLine = { fg = c.fg_dim, bg = c.bg_darker },
    StatusLineNC = { fg = c.fg_muted, bg = c.bg_darker },
    WinBar = { fg = c.fg, bold = true },
    WinBarNC = { fg = c.fg_muted },
    VertSplit = { fg = subtle },
    WinSeparator = { fg = subtle },
    NonText = { fg = c.fg_muted },
    MatchParen = { fg = c.match, bold = true },
    ErrorMsg = { fg = c.error },
    WarningMsg = { fg = c.warning },
    ModeMsg = { fg = c.fg_dim },
    MoreMsg = { fg = c.info },
    Question = { fg = c.info },

    -- Standard highlight groups (for fallback links)
    Title = { fg = c.header, bold = true },
    Comment = { fg = c.fg_muted, italic = true },
    Special = { fg = c.metadata },
    Identifier = { fg = c.fg },
    Directory = { fg = c.section },
    String = { fg = c.page },
    Statement = { fg = c.section },
    Function = { fg = c.chapter },
    Todo = { fg = c.bg, bg = c.todo, bold = true },

    -- Diagnostics
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warning },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.hint },

    -- Spelling
    SpellBad = { undercurl = true, sp = c.spell_bad },
    SpellCap = { undercurl = true, sp = c.spell_cap },
    SpellLocal = { undercurl = true, sp = c.info },
    SpellRare = { undercurl = true, sp = c.spell_rare },

    -- Neo-tree
    NeoTreeNormal = { fg = c.fg, bg = c.bg_darker },
    NeoTreeNormalNC = { fg = c.fg, bg = c.bg_darker },
    NeoTreeEndOfBuffer = { fg = c.bg_darker, bg = c.bg_darker },
    NeoTreeCursorLine = { bg = c.cursor_line },
    NeoTreeTitleBar = { fg = elevated, bg = c.fg_dim, bold = true },
    NeoTreeFloatBorder = { fg = c.fg_muted },
    NeoTreeFloatTitle = { fg = c.header, bold = true },

    -- Vimoire Navigator
    VimoireBook = { fg = c.book, bold = true },
    VimoireManuscript = { fg = c.manuscript, bold = true },
    VimoireSection = { fg = c.section, bold = true },
    VimoireChapter = { fg = c.chapter },
    VimoirePage = { fg = c.page },
    VimoirePlanning = { fg = c.planning, bold = true },
    VimoirePlanningSubfolder = { fg = c.planning, bold = true },
    VimoirePlanningItem = { fg = c.planning_item },
    VimoireExport = { fg = c.export, bold = true },
    VimoireExportFolder = { fg = c.export_folder, bold = true },
    VimoireExportFile = { fg = c.export_file },
    VimoireActionButton = { fg = elevated, bg = c.export, bold = true },
    VimoireWinbar = { fg = c.fg, bold = true },

    -- Vimoire Start Screen
    VimoireLogo = { fg = c.header, bold = true },
    VimoireLogoGlow = { fg = subtle },
    VimoireTagline = { fg = c.fg_muted, italic = true },
    VimoireStar = { fg = c.metadata },
    VimoireHeader = { fg = c.header, bold = true },
    VimoireProject = { fg = c.fg },
    VimoireProjectSelected = { fg = c.match, bold = true },
    VimoirePath = { fg = c.fg_muted },
    VimoireDate = { fg = c.fg_muted },
    VimoireAction = { fg = c.chapter },
    VimoireKey = { fg = c.todo, bold = true },

    -- Vimoire Prose (body text inherits Normal, markers subtle)
    vimoireH1 = { fg = c.header, bold = true },
    vimoireH2 = { fg = c.header, bold = true },
    vimoireH3 = { fg = c.header },
    vimoireH4 = { fg = c.header },
    vimoireH5 = { fg = c.fg_dim },
    vimoireH6 = { fg = c.fg_dim },
    vimoireSceneBreak = { fg = c.scene_break },
    vimoireBlockQuote = { fg = c.fg_dim, italic = true },
    vimoireFencedDiv = { fg = c.fg_muted },
    vimoireMetaChapter = { fg = c.metadata },
    vimoireMetaMark = { fg = c.metadata },
    vimoireMetaMarkText = { fg = c.metadata },
    vimoireMetaTodo = { fg = c.bg, bg = c.todo },
    vimoireMetaTodoText = { fg = c.bg, bg = c.todo },

    -- Inline formatting
    vimoireBoldItalicStyle = { fg = c.italic, bold = true, italic = true },
    vimoireBoldStyle = { bold = true },
    vimoireItalicStyle = { fg = c.italic, italic = true },
    vimoireUnderlineStyle = { underline = true },
    vimoireDialogue = { fg = c.dialogue },

    -- Statusline (context-colored backgrounds)
    VimoireStatusProse = { fg = c.fg_dim, bg = c.status_prose },
    VimoireStatusNotes = { fg = c.section, bg = c.status_notes },
    VimoireStatusPlanning = { fg = c.planning, bg = c.status_planning },
    VimoireStatusExport = { fg = c.export, bg = c.status_export },

    -- Snacks picker (match Normal background, not NormalFloat)
    SnacksPickerList = { fg = c.fg, bg = c.bg },
    SnacksPickerListCursorLine = { bg = c.cursor_line },

    -- Comments
    VimoireComment = { bg = c.comment_bg },
    VimoireCommentSign = { fg = c.comment_sign },

    -- Plotting boards
    VimoirePlottingHeader = { fg = c.header, bg = c.plotting_header_bg, bold = true },
    VimoirePlottingBorder = { fg = c.plotting_border },

    -- CSS (for epub.css readability)
    cssProp = { fg = c.chapter },
    cssAttr = { fg = c.chapter },
    cssClassName = { fg = c.header },
    cssClassNameDot = { fg = c.header },
    cssIdentifier = { fg = c.header },
    cssTagName = { fg = c.section },
    cssColor = { fg = c.page },
    cssValueLength = { fg = c.page },
    cssValueNumber = { fg = c.page },
    cssUnitDecorators = { fg = c.fg_muted },
  }

  for name, spec in pairs(theme.overrides or {}) do
    groups[name] = spec
  end

  for name, spec in pairs(groups) do
    hl(0, name, spec)
  end
end

return apply
