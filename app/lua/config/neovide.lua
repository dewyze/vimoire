local config = require("vimoire.config")
local neovide = config.get("neovide")

-- Standard macOS keymaps (Neovide doesn't provide these)
vim.keymap.set({ "n", "i" }, "<D-s>", "<Cmd>w<CR>", { desc = "Save" })
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy" })
vim.keymap.set("v", "<D-x>", '"+d', { desc = "Cut" })
vim.keymap.set("n", "<D-v>", '"+P', { desc = "Paste" })
vim.keymap.set("v", "<D-v>", '"+P', { desc = "Paste" })
vim.keymap.set("c", "<D-v>", "<C-R>+", { desc = "Paste" })
vim.keymap.set("i", "<D-v>", "<C-R>+", { desc = "Paste" })

vim.opt.guifont = neovide.font
vim.opt.linespace = neovide.linespace
vim.g.neovide_padding_top = neovide.padding.top
vim.g.neovide_padding_left = neovide.padding.left
vim.g.neovide_padding_right = neovide.padding.right
vim.g.neovide_padding_bottom = neovide.padding.bottom
vim.g.neovide_scroll_animation_length = neovide.scroll_animation_length
vim.g.neovide_position_animation_length = 0
