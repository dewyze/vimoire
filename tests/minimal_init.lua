-- Minimal Neovim init for testing
-- Bootstraps lazy to make plugins available for tests

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim (minimal, just load plugins)
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
})

-- Disable netrw during tests
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set up leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Package path for tests
package.path = package.path .. ";app/lua/?.lua;app/lua/?/init.lua"

-- Add app to runtimepath so nvim_get_runtime_file() can find templates
vim.opt.rtp:prepend("app")
