return {
  "shortcuts/no-neck-pain.nvim",
  config = function()
    require("no-neck-pain").setup({
      width = 86,
      autocmds = {
        enableOnVimEnter = false,
      },
      buffers = {
        right = { enabled = true },
        left = { enabled = true },
        wo = {
          fillchars = "eob: ",
        },
      },
      integrations = {
        NeoTree = {
          position = "left",
          reopen = true, -- reopen neotree when NoNeckPain is toggled
        },
      },
    })
  end,
}
