vim.api.nvim_create_user_command("FindManuscript", function()
  require("vimoire.navigation.picker").manuscript()
end, { desc = "Browse manuscript" })

vim.api.nvim_create_user_command("FindCharacters", function()
  require("vimoire.navigation.picker").characters()
end, { desc = "Browse characters" })

vim.api.nvim_create_user_command("FindSettings", function()
  require("vimoire.navigation.picker").settings()
end, { desc = "Browse settings" })

vim.api.nvim_create_user_command("FindReference", function()
  require("vimoire.navigation.picker").reference()
end, { desc = "Browse reference" })

vim.api.nvim_create_user_command("Find", function()
  require("vimoire.navigation.picker").navigate()
end, { desc = "Browse all entries (smart finder)" })

vim.api.nvim_create_user_command("FindPlanning", function()
  require("vimoire.navigation.picker").planning()
end, { desc = "Browse planning (characters, settings, reference)" })

vim.api.nvim_create_user_command("FindExports", function()
  require("vimoire.navigation.picker").exports()
end, { desc = "Browse exports" })

vim.api.nvim_create_user_command("OpenProse", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end

  local item = state.items[item_id]
  if not item then return end

  local prose_path = item:text_path()
  if not prose_path then return end

  vim.cmd("edit " .. prose_path)
  vim.b.vimoire_item_id = item.id
end, { desc = "Jump to prose for current entry" })
