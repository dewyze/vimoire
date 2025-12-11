local M = {}

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
end

return M
