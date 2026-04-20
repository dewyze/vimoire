local state = require("vimoire.state")
local ActionItem = require("vimoire.core.action_item")
local Path = require("plenary.path")

local M = {
  name = "export",
  display_name = "󰈙 Export",
  default_config = {
    window = {},
    renderers = {
      export = { { "indent" }, { "icon" }, { "name" } },
      export_folder = { { "indent" }, { "icon" }, { "name" } },
      export_file = { { "indent" }, { "icon" }, { "name" } },
      action = { { "indent" }, { "icon" }, { "name" } },
    },
  },
}

local function list_configs()
  local config_dir = state.manuscript.root .. "/exports/configs"
  local configs = {}
  local path = Path:new(config_dir)
  if path:exists() then
    for _, file in ipairs(vim.fn.glob(config_dir .. "/*.yml", false, true)) do
      local name = vim.fn.fnamemodify(file, ":t:r")
      table.insert(configs, name)
    end
  end
  return configs
end

local function run_export_picker()
  local configs = list_configs()
  if #configs == 0 then
    vim.notify("No export configs found. Run 'Generate Config' first.", vim.log.levels.WARN)
    return
  end

  vim.ui.select(configs, { prompt = "Select config:" }, function(choice)
    if choice then
      vim.cmd("Export " .. choice)
      state:rebuild()
      local manager = require("neo-tree.sources.manager")
      manager.refresh("export")
    end
  end)
end

local function node_from_item(item)
  return {
    id = item.id,
    name = item:display_name(),
    type = item.kind,
    path = item:text_path(),
    extra = item.action and { action = function() return item:action() end } or nil,
  }
end

local function generate_config_action()
  vim.ui.input({ prompt = "Config name: ", default = "default" }, function(name)
    if not name or name:match("^%s*$") then return end
    vim.cmd("ExportConfig " .. name)
    state:rebuild()
    local manager = require("neo-tree.sources.manager")
    manager.refresh("export")
  end)
end

local function build_action_nodes()
  local generate_config = ActionItem.new("action_generate_config", "Generate Config", generate_config_action)

  local run_export = ActionItem.new("action_run_export", "Run Export...", run_export_picker)

  return {
    node_from_item(generate_config),
    node_from_item(run_export),
  }
end

local function build_items_nodes(items, expanded_ids)
  local nodes = {}
  for _, item_data in ipairs(items) do
    local item = state.items[item_data.id]
    if not item then
      vim.notify("No item for id: " .. item_data.id, vim.log.levels.ERROR)
    else
      local node = node_from_item(item)
      if item.items then
        table.insert(expanded_ids, item.id)
        node.children = #item.items > 0 and build_items_nodes(item.items, expanded_ids) or {}
        node.loaded = true
      end
      table.insert(nodes, node)
    end
  end
  return nodes
end

function M.navigate(state_param, path, path_to_reveal, callback)
  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  state_param.path = path or state.manuscript.root

  local ok, err = pcall(function()
    local expanded_ids = { "export", "export_templates", "export_configs", "export_output" }

    local export_node = node_from_item(state.items["export"])
    local action_nodes = build_action_nodes()
    local folder_nodes = build_items_nodes(state.items["export"].items, expanded_ids)

    -- Action nodes at top, then folders
    export_node.children = vim.list_extend(action_nodes, folder_nodes)
    export_node.loaded = true

    state_param.default_expanded_nodes = expanded_ids

    local renderer = require("neo-tree.ui.renderer")
    renderer.show_nodes({ export_node }, state_param)
  end)

  if not ok then
    vim.notify("navigate error: " .. err, vim.log.levels.ERROR)
  end

  if callback then
    callback()
  end
end

function M.setup(config, global_config)
  -- No special setup needed
end

return M
