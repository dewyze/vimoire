local config = require("vimoire.config")
local keymaps = config.get("keymaps")

-- Finder keymaps (snacks-based)
if keymaps.finder.navigate then
  vim.keymap.set("n", keymaps.finder.navigate, ":VimoireNavigate<CR>", { desc = "Vimoire: navigate" })
end
if keymaps.finder.manuscript then
  vim.keymap.set("n", keymaps.finder.manuscript, ":VimoireManuscript<CR>", { desc = "Vimoire: manuscript" })
end
if keymaps.finder.characters then
  vim.keymap.set("n", keymaps.finder.characters, ":VimoireCharacters<CR>", { desc = "Vimoire: characters" })
end
if keymaps.finder.settings then
  vim.keymap.set("n", keymaps.finder.settings, ":VimoireSettings<CR>", { desc = "Vimoire: settings" })
end
if keymaps.finder.reference then
  vim.keymap.set("n", keymaps.finder.reference, ":VimoireReference<CR>", { desc = "Vimoire: reference" })
end
if keymaps.finder.exports then
  vim.keymap.set("n", keymaps.finder.exports, ":VimoireExports<CR>", { desc = "Vimoire: exports" })
end

-- Navigator keymaps
if keymaps.navigator.toggle then
  vim.keymap.set("n", keymaps.navigator.toggle, ":Neotree toggle source=manuscript<CR>", { desc = "Vimoire: toggle navigator" })
end

if keymaps.navigator.reveal then
  vim.keymap.set("n", keymaps.navigator.reveal, function()
    local path_util = require("vimoire.util.path")
    local source = path_util.navigator_source(vim.fn.expand("%:p"))
    vim.cmd("Neotree reveal source=" .. source)
  end, { desc = "Vimoire: find in navigator" })
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
if keymaps.views and keymaps.views.focus then
  vim.keymap.set("n", keymaps.views.focus, ":VimoireFocus<CR>", { desc = "Vimoire: toggle focus mode" })
end
if keymaps.views and keymaps.views.focus_redistribute then
  vim.keymap.set("n", keymaps.views.focus_redistribute, ":VimoireFocusRedistribute<CR>", { desc = "Vimoire: recalculate focus margins" })
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

-- Buffer keymaps
if keymaps.buffer then
  if keymaps.buffer.notes then
    vim.keymap.set("n", keymaps.buffer.notes, ":VimoireNotes<CR>", { desc = "Vimoire: open notes" })
  end
  if keymaps.buffer.marks then
    vim.keymap.set("n", keymaps.buffer.marks, ":VimoireMarks<CR>", { desc = "Vimoire: browse marks" })
  end
  if keymaps.buffer.toggle_kind then
    vim.keymap.set("n", keymaps.buffer.toggle_kind, ":VimoireToggleKind<CR>", { desc = "Vimoire: toggle chapter/page" })
  end
  if keymaps.buffer.insert_mark then
    vim.keymap.set("n", keymaps.buffer.insert_mark, ":VimoireInsertMark<CR>", { desc = "Vimoire: insert mark" })
  end
end

-- Images keymaps
if keymaps.images then
  if keymaps.images.insert then
    vim.keymap.set("n", keymaps.images.insert, ":VimoireInsertImage<CR>", { desc = "Vimoire: insert image" })
  end
end

-- Editing keymaps
if keymaps.editing then
  if keymaps.editing.append_display_line then
    vim.keymap.set("n", keymaps.editing.append_display_line, "g$a", { desc = "Append at end of display line" })
  end
end

-- General editor keymaps
vim.keymap.set("n", "<leader>nh", ":noh<CR>", { desc = "Clear search highlight" })
