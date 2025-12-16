require("config.lazy")
require("config.defaults")
require("vimoire.highlights").setup()

-- Load colorscheme with precedence: user config > preferences > default
local colorscheme = require("vimoire.config").effective_colorscheme()
vim.cmd.colorscheme(colorscheme)

require("config.keymaps")
require("config.commands")

if vim.g.neovide then
  require("config.neovide")
end

require("vimoire.filetypes").setup()

vim.api.nvim_create_autocmd("User", {
  pattern = "VimoireProjectLoaded",
  callback = function()
    require("vimoire.setup").on_manuscript_loaded()
  end,
})

require("vimoire.setup").load_manuscript()
