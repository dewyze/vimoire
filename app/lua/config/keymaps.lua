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
  vim.keymap.set("n", keymaps.navigator.toggle, ":Neotree toggle source=vimoire<CR>", { desc = "Vimoire: toggle navigator" })
end
