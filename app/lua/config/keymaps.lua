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
set("n", keymaps.finder.smart, ":Find<CR>", { desc = "Vimoire: smart finder" })
set("n", keymaps.finder.manuscript, ":FindManuscript<CR>", { desc = "Vimoire: manuscript" })
set("n", keymaps.finder.planning, ":FindPlanning<CR>", { desc = "Vimoire: planning" })
set("n", keymaps.finder.snippets, ":FindSnippets<CR>", { desc = "Vimoire: snippets" })
set("n", keymaps.finder.exports, ":FindExports<CR>", { desc = "Vimoire: exports" })

-- Navigator keymaps
set("n", keymaps.navigator.toggle, ":Neotree toggle source=manuscript<CR>", { desc = "Vimoire: toggle navigator" })
set("n", keymaps.navigator.reveal, function()
  local path_util = require("vimoire.util.path")
  local source = path_util.navigator_source(vim.fn.expand("%:p"))
  vim.cmd("Neotree reveal source=" .. source)
end, { desc = "Vimoire: reveal in navigator" })
set("n", keymaps.navigator.manuscript, ":NavigateManuscript<CR>", { desc = "Vimoire: manuscript view" })
set("n", keymaps.navigator.export, ":NavigateExport<CR>", { desc = "Vimoire: export view" })

-- Views keymaps
if keymaps.views then
  set("n", keymaps.views.home, ":ViewHome<CR>", { desc = "Vimoire: home" })
  set("n", keymaps.views.focus, ":ViewFocus<CR>", { desc = "Vimoire: toggle focus mode" })
end
vim.keymap.set("n", "<C-\\>", "<Cmd>ViewFocus<CR>", { desc = "Vimoire: toggle focus mode" })
vim.keymap.set("n", "<D-d>", "<Cmd>ViewFocus<CR>", { desc = "Vimoire: toggle focus mode" })

-- Writing context keymaps
if keymaps.writing then
  set("n", keymaps.writing.notes, ":OpenNotes<CR>", { desc = "Vimoire: open notes" })
  set("n", keymaps.writing.delete_notes, ":DeleteNotes<CR>", { desc = "Vimoire: delete notes" })
  set("n", keymaps.writing.marks, ":FindMarks<CR>", { desc = "Vimoire: browse marks" })
  set("n", keymaps.writing.toggle_kind, ":ToggleKind<CR>", { desc = "Vimoire: toggle chapter/page" })
  set("n", keymaps.writing.prose, ":OpenProse<CR>", { desc = "Vimoire: jump to prose" })
end

-- Insert keymaps
if keymaps.insert then
  set("n", keymaps.insert.mark, ":InsertMark<CR>", { desc = "Vimoire: insert mark" })
  set("n", keymaps.insert.image, ":InsertImage<CR>", { desc = "Vimoire: insert image" })
end

-- Snippets keymaps
if keymaps.snippets then
  set("n", keymaps.snippets.insert, ":FindSnippets<CR>", { desc = "Vimoire: insert snippet" })
  set("v", keymaps.snippets.extract, ":SnippetExtract<CR>", { desc = "Vimoire: extract snippet" })
end

-- Comments keymaps
if keymaps.comments then
  set({ "n", "v" }, keymaps.comments.create, ":CommentCreate<CR>", { desc = "Vimoire: create comment" })
  set("n", keymaps.comments.edit, ":CommentEdit<CR>", { desc = "Vimoire: edit comment" })
  set("n", keymaps.comments.delete, ":CommentDelete<CR>", { desc = "Vimoire: delete comment" })
  set("n", keymaps.comments.view, ":CommentView<CR>", { desc = "Vimoire: view comment" })
  set("n", keymaps.comments.toggle, ":CommentToggle<CR>", { desc = "Vimoire: toggle comments" })
  set("n", keymaps.comments.list, ":CommentList<CR>", { desc = "Vimoire: list comments" })
  set("n", keymaps.comments.next, ":CommentNext<CR>", { desc = "Vimoire: next comment" })
  set("n", keymaps.comments.prev, ":CommentPrev<CR>", { desc = "Vimoire: prev comment" })
end

-- Misc keymaps
if keymaps.misc then
  set("n", keymaps.misc.clear_highlight, ":noh<CR>", { desc = "Clear search highlight" })
end
