vim.api.nvim_create_user_command("VimoireHome", function()
  require("vimoire.setup").show_start_screen()
end, { desc = "Show Vimoire start screen" })

vim.api.nvim_create_user_command("VimoireNotes", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end

  local item = state.items[item_id]
  if not item then return end

  local notes_path = item:notes_path()
  if not notes_path then return end

  vim.cmd("edit " .. notes_path)
  vim.b.vimoire_item_id = item.id
end, { desc = "Open notes for current chapter/page" })
