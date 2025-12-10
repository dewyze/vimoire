require("config.lazy")
require("config.defaults")
require("config.keymaps")
require("config.commands")

if vim.g.neovide then
  require("config.neovide")
end

require("vimoire.setup").load_manuscript()
