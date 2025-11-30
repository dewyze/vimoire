return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      sources = {
        "vimoire.navigation.neotree_source",
      },
      source_selector = {
        winbar = true,
        sources = {
          { source = "vimoire" },
        },
      },
    })

    vim.keymap.set("n", "<LocalLeader>nt", function()
      vim.cmd("Neotree source=vimoire")
    end, { noremap = true, silent = true })
  end,
}
