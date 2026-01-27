local M = {}

local state = require("vimoire.state")
local config = require("vimoire.config")

-- Display-line-first navigation: plain keys work on display lines,
-- g-prefix escapes to buffer lines (inverse of vim defaults)
local function setup_display_line_navigation()
  if not config.get("editor.visual_line_navigation") then
    return
  end

  -- Movement
  vim.keymap.set("n", "j", "gj", { buffer = true, desc = "Down (display line)" })
  vim.keymap.set("n", "k", "gk", { buffer = true, desc = "Up (display line)" })
  vim.keymap.set("n", "gj", "j", { buffer = true, desc = "Down (buffer line)" })
  vim.keymap.set("n", "gk", "k", { buffer = true, desc = "Up (buffer line)" })

  -- Line ends
  vim.keymap.set("n", "$", "g$", { buffer = true, desc = "End of display line" })
  vim.keymap.set("n", "0", "g0", { buffer = true, desc = "Start of display line" })
  vim.keymap.set("n", "g$", "$", { buffer = true, desc = "End of buffer line" })
  vim.keymap.set("n", "g0", "0", { buffer = true, desc = "Start of buffer line" })

  -- Insert/Append
  vim.keymap.set("n", "A", "g$a", { buffer = true, desc = "Append at display line end" })
  vim.keymap.set("n", "I", "g^i", { buffer = true, desc = "Insert at display line start" })
  vim.keymap.set("n", "gA", "A", { buffer = true, desc = "Append at buffer line end" })
  vim.keymap.set("n", "gI", "I", { buffer = true, desc = "Insert at buffer line start" })
end

-- Sentence navigation for single-space prose: ) and ( find . + space + capital
local function setup_sentence_navigation()
  -- Forward sentence: find period followed by space(s) and capital letter
  vim.keymap.set("n", ")", function()
    vim.fn.search([[\.\s\+\u]], "W")
  end, { buffer = true, desc = "Next sentence" })

  -- Backward sentence: find period followed by space(s) and capital letter
  vim.keymap.set("n", "(", function()
    vim.fn.search([[\.\s\+\u]], "bW")
  end, { buffer = true, desc = "Previous sentence" })
end

local function setup_markdown_buffer()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.cursorline = true

  vim.wo.spell = false

  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
  vim.bo.expandtab = true

  setup_display_line_navigation()
end

local function setup_prose_buffer()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.breakindent = false
  vim.bo.textwidth = 0
  vim.wo.cursorline = true
  vim.wo.signcolumn = "yes"

  vim.bo.autoindent = true

  vim.wo.spell = true
  vim.bo.spelllang = "en"
  vim.bo.spellfile = state.manuscript.root .. "/spell/en.add"

  setup_display_line_navigation()
  setup_sentence_navigation()
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
