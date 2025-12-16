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

local THEMES = {
  "vimoire-inkwell",
  "vimoire-parchment",
  "vimoire-vellum",
  "vimoire-umbra",
  "vimoire-lumen",
}

vim.api.nvim_create_user_command("VimoireTheme", function()
  vim.ui.select(THEMES, {
    prompt = "Select theme:",
  }, function(choice)
    if not choice then return end

    vim.cmd.colorscheme(choice)
    require("vimoire.core.preferences").set("colorscheme", choice)
  end)
end, { desc = "Select and save Vimoire colorscheme" })

vim.api.nvim_create_user_command("VimoireExportConfig", function(opts)
  local state = require("vimoire.state")
  local config = require("vimoire.export.config")
  local Path = require("plenary.path")

  local name = opts.args ~= "" and opts.args or "default"
  local root = state.manuscript.root
  local config_dir = root .. "/exports/configs"
  local config_path = config_dir .. "/" .. name .. ".yml"

  vim.fn.mkdir(config_dir, "p")

  local yaml
  local path = Path:new(config_path)
  if path:exists() then
    local existing = path:read()
    yaml = config.update(state, existing)
  else
    yaml = config.generate(state)
  end

  path:write(yaml, "w")
  state:load(root)
  vim.cmd("edit " .. config_path)
end, { nargs = "?", desc = "Generate or update export config" })

vim.api.nvim_create_user_command("VimoireExport", function(opts)
  local state = require("vimoire.state")
  local export = require("vimoire.export")
  local Path = require("plenary.path")

  local name = opts.args ~= "" and opts.args or "default"
  local config_path = state.manuscript.root .. "/exports/configs/" .. name .. ".yml"

  if not Path:new(config_path):exists() then
    vim.notify("Config not found. Run :VimoireExportConfig " .. name .. " first", vim.log.levels.ERROR)
    return
  end

  vim.notify("Exporting...", vim.log.levels.INFO)

  local result = export.run_with_config(state, config_path)

  if result.success then
    vim.notify("Export complete: " .. result.output_path, vim.log.levels.INFO)
  else
    vim.notify("Export failed: " .. result.error, vim.log.levels.ERROR)
  end
end, { nargs = "?", desc = "Run export with config" })
