local config = require("vimoire.config")
local neovide = config.get("neovide")

vim.keymap.set('n', '<D-s>', ':w<CR>')
vim.keymap.set('v', '<D-c>', '"+y')
vim.keymap.set('n', '<D-v>', '"+P')
vim.keymap.set('v', '<D-v>', '"+P')
vim.keymap.set('c', '<D-v>', '<C-R>+')
vim.keymap.set('i', '<D-v>', '<C-R>+')

vim.opt.guifont = neovide.font
vim.opt.linespace = neovide.linespace
vim.g.neovide_padding_top = neovide.padding.top
vim.g.neovide_padding_left = neovide.padding.left
vim.g.neovide_padding_right = neovide.padding.right
vim.g.neovide_padding_bottom = neovide.padding.bottom
vim.g.neovide_scroll_animation_length = neovide.scroll_animation_length
