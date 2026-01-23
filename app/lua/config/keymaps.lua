local config = require("vimoire.config")
local keymaps = config.get("keymaps")

-- Finder keymaps
if keymaps.finder.smart then
  vim.keymap.set("n", keymaps.finder.smart, ":VimoireNavigate<CR>", { desc = "Vimoire: smart finder" })
end
if keymaps.finder.smart_alt then
  vim.keymap.set("n", keymaps.finder.smart_alt, ":VimoireNavigate<CR>", { desc = "Vimoire: smart finder" })
end
if keymaps.finder.manuscript then
  vim.keymap.set("n", keymaps.finder.manuscript, ":VimoireManuscript<CR>", { desc = "Vimoire: manuscript" })
end
if keymaps.finder.planning then
  vim.keymap.set("n", keymaps.finder.planning, ":VimoirePlanning<CR>", { desc = "Vimoire: planning" })
end
if keymaps.finder.snippets then
  vim.keymap.set("n", keymaps.finder.snippets, ":VimoireSnippets<CR>", { desc = "Vimoire: snippets" })
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
  end, { desc = "Vimoire: reveal in navigator" })
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

-- Writing context keymaps
if keymaps.writing then
  if keymaps.writing.notes then
    vim.keymap.set("n", keymaps.writing.notes, ":VimoireNotes<CR>", { desc = "Vimoire: open notes" })
  end
  if keymaps.writing.marks then
    vim.keymap.set("n", keymaps.writing.marks, ":VimoireMarks<CR>", { desc = "Vimoire: browse marks" })
  end
  if keymaps.writing.toggle_kind then
    vim.keymap.set("n", keymaps.writing.toggle_kind, ":VimoireToggleKind<CR>", { desc = "Vimoire: toggle chapter/page" })
  end
  if keymaps.writing.prose then
    vim.keymap.set("n", keymaps.writing.prose, ":VimoireProse<CR>", { desc = "Vimoire: jump to prose" })
  end
end

-- Insert keymaps
if keymaps.insert then
  if keymaps.insert.mark then
    vim.keymap.set("n", keymaps.insert.mark, ":VimoireInsertMark<CR>", { desc = "Vimoire: insert mark" })
  end
  if keymaps.insert.image then
    vim.keymap.set("n", keymaps.insert.image, ":VimoireInsertImage<CR>", { desc = "Vimoire: insert image" })
  end
end

-- Snippets keymaps
if keymaps.snippets then
  if keymaps.snippets.insert then
    vim.keymap.set("n", keymaps.snippets.insert, ":VimoireSnippets<CR>", { desc = "Vimoire: insert snippet" })
  end
  if keymaps.snippets.extract then
    vim.keymap.set("v", keymaps.snippets.extract, ":VimoireSnippetExtract<CR>", { desc = "Vimoire: extract snippet" })
  end
end

-- Misc keymaps
if keymaps.misc then
  if keymaps.misc.clear_highlight then
    vim.keymap.set("n", keymaps.misc.clear_highlight, ":noh<CR>", { desc = "Clear search highlight" })
  end
  if keymaps.misc.save then
    vim.keymap.set({ "n", "i" }, keymaps.misc.save, "<Cmd>w<CR>", { desc = "Save" })
  end
  if keymaps.misc.copy then
    vim.keymap.set("v", keymaps.misc.copy, '"+y', { desc = "Copy" })
  end
  if keymaps.misc.paste then
    vim.keymap.set({ "n", "i" }, keymaps.misc.paste, '<Cmd>set paste<CR><C-r>+<Cmd>set nopaste<CR>', { desc = "Paste" })
  end
end
