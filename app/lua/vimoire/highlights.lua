-- Fallback highlights for Vimoire UI groups
-- Applied after colorscheme loads, only if not already defined
-- Prose syntax highlights are in syntax/vimoire_prose.vim

local M = {}

local function apply_defaults()
  local function default_link(name, target)
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end

  -- Navigator groups
  default_link("VimoireBook", "Identifier")
  default_link("VimoireManuscript", "Title")
  default_link("VimoireSection", "Statement")
  default_link("VimoireChapter", "Function")
  default_link("VimoirePage", "String")
  default_link("VimoirePlanning", "Directory")
  default_link("VimoirePlanningSubfolder", "Directory")
  default_link("VimoirePlanningItem", "Normal")
  default_link("VimoireWinbar", "Title")

  -- Start screen groups
  default_link("VimoireLogo", "Title")
  default_link("VimoireLogoGlow", "Comment")
  default_link("VimoireTagline", "Comment")
  default_link("VimoireStar", "Special")
  default_link("VimoireHeader", "Title")
  default_link("VimoireProject", "Normal")
  default_link("VimoireProjectSelected", "CurSearch")
  default_link("VimoirePath", "Comment")
  default_link("VimoireDate", "Comment")
  default_link("VimoireAction", "String")
  default_link("VimoireKey", "Special")
end

function M.setup()
  -- Apply defaults after any colorscheme loads
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("VimoireHighlights", { clear = true }),
    callback = apply_defaults,
  })

  -- Also apply now (colorscheme may already be loaded)
  apply_defaults()
end

return M
