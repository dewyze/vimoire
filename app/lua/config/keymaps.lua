local config = require("vimoire.config")
local keymaps = config.get("keymaps")

-- Finder keymaps
for name, key in pairs(keymaps.finder) do
  if key then
    vim.keymap.set("n", key, ":Telescope vimoire " .. name .. "<CR>", { desc = "Vimoire: " .. name })
  end
end

-- Navigator keymaps
if keymaps.navigator.toggle then
  vim.keymap.set("n", keymaps.navigator.toggle, ":Neotree toggle source=manuscript<CR>", { desc = "Vimoire: toggle navigator" })
end

if keymaps.navigator.reveal then
  vim.keymap.set("n", keymaps.navigator.reveal, ":Neotree reveal source=manuscript<CR>", { desc = "Vimoire: find in navigator" })
end

if keymaps.navigator.manuscript then
  vim.keymap.set("n", keymaps.navigator.manuscript, ":Neotree source=manuscript<CR>", { desc = "Vimoire: manuscript view" })
end

if keymaps.navigator.export then
  vim.keymap.set("n", keymaps.navigator.export, ":Neotree source=export<CR>", { desc = "Vimoire: export view" })
end

-- Views keymaps
if keymaps.views and keymaps.views.home then
  vim.keymap.set("n", keymaps.views.home, ":VimoireHome<CR>", { desc = "Vimoire: home" })
end

-- Snippets keymaps
if keymaps.snippets then
  if keymaps.snippets.browse then
    vim.keymap.set("n", keymaps.snippets.browse, ":VimoireSnippets<CR>", { desc = "Vimoire: browse snippets" })
  end
  if keymaps.snippets.extract then
    vim.keymap.set("v", keymaps.snippets.extract, ":VimoireSnippetExtract<CR>", { desc = "Vimoire: extract snippet" })
  end
end
