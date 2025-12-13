local M = {}

local state = require("vimoire.state")
local config = require("vimoire.config")

local function setup_visual_line_navigation()
  if config.get("editor.visual_line_navigation") then
    vim.keymap.set("n", "j", "gj", { buffer = true })
    vim.keymap.set("n", "k", "gk", { buffer = true })
  end
end

local function setup_markdown_buffer()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.cursorline = true

  vim.wo.spell = false

  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
  vim.bo.expandtab = true

  setup_visual_line_navigation()
end

local function setup_prose_buffer()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.breakindent = false
  vim.bo.textwidth = 0
  vim.wo.cursorline = true

  vim.bo.autoindent = true

  vim.wo.spell = true
  vim.bo.spelllang = "en"
  vim.bo.spellfile = state.manuscript.root .. "/spell/en.add"

  setup_visual_line_navigation()
end

function M.setup()
  vim.filetype.add({
    filename = {
      ["prose.md"] = "vimoire_prose",
      ["notes.md"] = "vimoire_markdown",
      ["text.md"] = "vimoire_markdown",
    },
  })

  vim.treesitter.language.register("markdown", "vimoire_markdown")

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "vimoire_prose",
    callback = setup_prose_buffer,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "vimoire_markdown",
    callback = setup_markdown_buffer,
  })
end

return M
