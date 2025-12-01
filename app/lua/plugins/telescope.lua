return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({})
    telescope.load_extension("vimoire")

    vim.keymap.set("n", "<LocalLeader>ff", function()
      telescope.extensions.vimoire.navigate()
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<C-p>", function()
      telescope.extensions.vimoire.navigate()
    end, { noremap = true, silent = true })
  end,
}
