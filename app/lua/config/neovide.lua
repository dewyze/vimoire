-- Set Command/Paste key bindings
vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
vim.keymap.set('v', '<D-c>', '"+y') -- Copy
vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
vim.keymap.set('i', '<D-v>', '<C-R>+') -- Paste insert mode

-- Display Configurations
vim.opt.guifont = "Iosevka Term Slab:h13"
vim.opt.linespace = 8
vim.g.neovide_padding_top = 100
vim.g.neovide_padding_left = 20
vim.g.neovide_padding_right = 20
vim.g.neovide_padding_bottom = 20
vim.g.neovide_scroll_animation_length = 0.3
