vim.api.nvim_create_user_command("VimoireHome", function()
  require("vimoire.setup").show_start_screen()
end, { desc = "Show Vimoire start screen" })
