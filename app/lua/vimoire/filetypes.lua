local M = {}

local function setup_prose_buffer()
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.breakindent = false
  vim.bo.textwidth = 0
  vim.wo.cursorline = true

  vim.keymap.set("n", "j", "gj", { buffer = true })
  vim.keymap.set("n", "k", "gk", { buffer = true })
end

function M.setup()
  vim.filetype.add({
    filename = {
      ["prose.md"] = "vimoire_prose",
      ["notes.md"] = "vimoire_markdown",
      ["text.md"] = "vimoire_markdown",
    },
  })

  vim.treesitter.language.register("markdown", "vimoire_prose")
  vim.treesitter.language.register("markdown", "vimoire_markdown")

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "vimoire_prose",
    callback = setup_prose_buffer,
  })
end

return M
