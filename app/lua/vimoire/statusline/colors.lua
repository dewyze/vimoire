-- Statusline highlight group definitions
-- Each context type (prose, notes, planning, export) gets distinct colors
-- Actual colors are set by colorschemes; this provides fallback links

local M = {}

-- Context types for statusline coloring
M.CONTEXTS = {
  PROSE = "prose",
  NOTES = "notes",
  PLANNING = "planning",
  EXPORT = "export",
  DEFAULT = "default",
}

-- Map highlight group names
M.HIGHLIGHTS = {
  prose = "VimoireStatusProse",
  notes = "VimoireStatusNotes",
  planning = "VimoireStatusPlanning",
  export = "VimoireStatusExport",
  default = "StatusLine",
}

local function apply_defaults()
  local function default_link(name, target)
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end

  -- Fallback links if colorscheme doesn't define these
  default_link("VimoireStatusProse", "StatusLine")
  default_link("VimoireStatusNotes", "StatusLine")
  default_link("VimoireStatusPlanning", "StatusLine")
  default_link("VimoireStatusExport", "StatusLine")
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("VimoireStatuslineColors", { clear = true }),
    callback = apply_defaults,
  })

  apply_defaults()
end

return M
