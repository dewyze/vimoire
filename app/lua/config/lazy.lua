-- Recommended setup from https://lazy.folke.io/installation

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
-- vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load user plugins from ~/.vimoire/config.lua
local user_plugins = {}
local user_config_path = vim.fn.expand("~/.vimoire/config.lua")
if vim.fn.filereadable(user_config_path) == 1 then
  local ok, cfg = pcall(dofile, user_config_path)
  if ok and type(cfg) == "table" and cfg.plugins then
    user_plugins = cfg.plugins
  end
end

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
    user_plugins,
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
})
