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

-- In --headless mode, lazy.nvim doesn't eagerly load `lazy = false` plugins
-- (VimEnter doesn't fire early enough). Manually add snacks to rtp so
-- require("snacks") resolves when vimoire.comments imports it.
local snacks_dir = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
if (vim.uv or vim.loop).fs_stat(snacks_dir) then
  vim.opt.rtp:append(snacks_dir)
end

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

-- Prevent plugin-provided tests/helpers.lua (e.g. telescope's) from shadowing
-- ours via the runtimepath loader. Insert a high-priority searcher that
-- resolves tests.helpers to our file. Lazy (deferred) so the file's own
-- requires resolve when a spec first calls it, not at init time.
table.insert(package.loaders, 1, function(modname)
  if modname == "tests.helpers" then
    return loadfile(vim.fn.getcwd() .. "/tests/helpers.lua")
  end
end)
