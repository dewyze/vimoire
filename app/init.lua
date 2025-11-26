require("config.lazy")
require("config.defaults")

if vim.g.neovide then
  require("config.neovide")
end

require("vimoire.setup").load_manuscript()
