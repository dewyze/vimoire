return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local vimoire_config = require("vimoire.config")
    local mouse_mode = vimoire_config.get("ui.mouse_mode")

    local mouse_mappings = {}
    if mouse_mode == "single_click" then
      mouse_mappings["<LeftRelease>"] = "open"
      mouse_mappings["<2-LeftMouse>"] = "noop"
    else
      mouse_mappings["<2-LeftMouse>"] = "open"
    end

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
      window = {
        mappings = mouse_mappings,
      },
    })

    vim.keymap.set("n", "<LocalLeader>nt", function()
      vim.cmd("Neotree source=vimoire")
    end, { noremap = true, silent = true })
  end,
}
