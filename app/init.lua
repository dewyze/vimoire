require("config.lazy")
require("config.defaults")
require("config.keymaps")

if vim.g.neovide then
  require("config.neovide")
end

require("vimoire.setup").load_manuscript()
