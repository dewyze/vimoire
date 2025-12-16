vim.api.nvim_create_user_command("VimoireHome", function()
  require("vimoire.setup").show_dashboard()
end, { desc = "Show Vimoire dashboard" })

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
    snacks = { layout = { hidden = { "input" }, preview = false } },
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

local function open_file(path)
  if vim.ui.open then
    vim.ui.open(path)
  elseif vim.fn.has("mac") == 1 then
    vim.fn.system({ "open", path })
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system({ "xdg-open", path })
  end
end

vim.api.nvim_create_user_command("VimoireExport", function(opts)
  local state = require("vimoire.state")
  local export = require("vimoire.export")
  local config_mod = require("vimoire.config")
  local Path = require("plenary.path")

  -- Parse args: [config_name] [--no-open]
  local args = vim.split(opts.args, "%s+", { trimempty = true })
  local name = "default"
  local no_open = false

  for _, arg in ipairs(args) do
    if arg == "--no-open" then
      no_open = true
    elseif not arg:match("^%-%-") then
      name = arg
    end
  end

  local config_path = state.manuscript.root .. "/exports/configs/" .. name .. ".yml"

  if not Path:new(config_path):exists() then
    vim.notify("Config not found. Run :VimoireExportConfig " .. name .. " first", vim.log.levels.ERROR)
    return
  end

  vim.notify("Exporting...", vim.log.levels.INFO)

  local result = export.run_with_config(state, config_path)

  if result.success then
    vim.notify("Export complete: " .. result.output_path, vim.log.levels.INFO)

    -- Auto-open unless disabled
    local auto_open = config_mod.get("export.auto_open")
    if auto_open and not no_open then
      open_file(result.output_path)
    end
  else
    local msg = "Export failed"
    if result.log_path then
      msg = msg .. ". See " .. result.log_path
    else
      msg = msg .. ": " .. result.error
    end
    vim.notify(msg, vim.log.levels.ERROR)
  end
end, { nargs = "*", desc = "Run export with config" })
