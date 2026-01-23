return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true },
    picker = {
      ui_select = true,
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["<C-/>"] = { "toggle_help_input", mode = { "n", "i" }, desc = "Toggle help" },
          },
        },
      },
    },
    notifier = { enabled = true },
  },
}
