local config = require("vimoire.config")
local keymaps = config.get("keymaps")

-- Supports both single keys and arrays of keys
local function set(modes, keys, cmd, opts)
  if not keys then return end
  local key_list = type(keys) == "table" and keys or { keys }
  for _, key in ipairs(key_list) do
    vim.keymap.set(modes, key, cmd, opts)
  end
end

-- Command palette (Neovide-only: Cmd+Shift+P always available)
vim.keymap.set({ "n", "i", "v" }, "<D-S-p>", "<Cmd>Palette<CR>", { desc = "Command palette" })
set({ "n", "v" }, keymaps.palette, "<Cmd>Palette<CR>", { desc = "Command palette" })

-- Finder keymaps
set("n", keymaps.finder.smart, ":Navigate<CR>", { desc = "Vimoire: smart finder" })
set("n", keymaps.finder.manuscript, ":Manuscript<CR>", { desc = "Vimoire: manuscript" })
set("n", keymaps.finder.planning, ":Planning<CR>", { desc = "Vimoire: planning" })
set("n", keymaps.finder.snippets, ":Snippets<CR>", { desc = "Vimoire: snippets" })
set("n", keymaps.finder.exports, ":Exports<CR>", { desc = "Vimoire: exports" })

-- Navigator keymaps
set("n", keymaps.navigator.toggle, ":Neotree toggle source=manuscript<CR>", { desc = "Vimoire: toggle navigator" })
set("n", keymaps.navigator.reveal, function()
  local path_util = require("vimoire.util.path")
  local source = path_util.navigator_source(vim.fn.expand("%:p"))
  vim.cmd("Neotree reveal source=" .. source)
end, { desc = "Vimoire: reveal in navigator" })
set("n", keymaps.navigator.manuscript, ":Neotree source=manuscript<CR>", { desc = "Vimoire: manuscript view" })
set("n", keymaps.navigator.export, ":Neotree source=export<CR>", { desc = "Vimoire: export view" })

-- Views keymaps
if keymaps.views then
  set("n", keymaps.views.home, ":Home<CR>", { desc = "Vimoire: home" })
  set("n", keymaps.views.focus, ":Focus<CR>", { desc = "Vimoire: toggle focus mode" })
end

-- Writing context keymaps
if keymaps.writing then
  set("n", keymaps.writing.notes, ":Notes<CR>", { desc = "Vimoire: open notes" })
  set("n", keymaps.writing.marks, ":Marks<CR>", { desc = "Vimoire: browse marks" })
  set("n", keymaps.writing.toggle_kind, ":ToggleKind<CR>", { desc = "Vimoire: toggle chapter/page" })
  set("n", keymaps.writing.prose, ":Prose<CR>", { desc = "Vimoire: jump to prose" })
end

-- Insert keymaps
if keymaps.insert then
  set("n", keymaps.insert.mark, ":InsertMark<CR>", { desc = "Vimoire: insert mark" })
  set("n", keymaps.insert.image, ":InsertImage<CR>", { desc = "Vimoire: insert image" })
end

-- Snippets keymaps
if keymaps.snippets then
  set("n", keymaps.snippets.insert, ":Snippets<CR>", { desc = "Vimoire: insert snippet" })
  set("v", keymaps.snippets.extract, ":SnippetExtract<CR>", { desc = "Vimoire: extract snippet" })
end

-- Misc keymaps
if keymaps.misc then
  set("n", keymaps.misc.clear_highlight, ":noh<CR>", { desc = "Clear search highlight" })
end
