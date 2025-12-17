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
      use_default_mappings = false,
      sources = {
        "vimoire.navigation.sources.manuscript",
        "vimoire.navigation.sources.export",
      },
      source_selector = {
        winbar = true,
        sources = {
          { source = "manuscript", display_name = "󱓷 Manuscript" },
          { source = "export", display_name = "󰈙 Export" },
        },
      },
      window = {
        position = "left",
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = mouse_mappings,
      },
      manuscript = {
        window = {
          mappings = {
            ["<cr>"] = "open",
            ["o"] = "open",
            ["s"] = "open_split",
            ["v"] = "open_vsplit",
            ["t"] = "toggle_node",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["e"] = "expand_all_nodes",
            ["q"] = "close_window",
            ["?"] = "show_help",
            ["R"] = "refresh",
            ["a"] = "add",
            ["r"] = "rename",
            ["d"] = "delete",
            ["n"] = "notes",
            ["m"] = "move",
            ["J"] = "move_down",
            ["K"] = "move_up",
          },
        },
      },
      export = {
        window = {
          mappings = {
            ["<cr>"] = "open",
            ["o"] = "open",
            ["s"] = "open_split",
            ["v"] = "open_vsplit",
            ["t"] = "toggle_node",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["e"] = "expand_all_nodes",
            ["q"] = "close_window",
            ["?"] = "show_help",
            ["R"] = "refresh",
            ["d"] = "delete",
          },
        },
      },
    })
  end,
}
