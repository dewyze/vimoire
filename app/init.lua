math.randomseed(os.time() + os.clock() * 1000)

-- Disable netrw immediately to prevent flash when opening directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bundle launches (open -a Vimoire) pass no --listen flag; claim the socket
-- here so bin/vimoire's probe can find and focus this instance. No-op when
-- the launcher already bound it.
pcall(vim.fn.serverstart, "/tmp/vimoire.sock")

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
