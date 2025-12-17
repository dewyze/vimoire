local state = require("vimoire.state")

local M = {
  name = "export",
  display_name = "󰈙 Export",
  default_config = {
    window = {},
    renderers = {
      export = { { "indent" }, { "icon" }, { "name" } },
      export_folder = { { "indent" }, { "icon" }, { "name" } },
      export_file = { { "indent" }, { "icon" }, { "name" } },
    },
  },
}

local function node_from_item(item)
  return {
    id = item.id,
    name = item:display_name(),
    type = item.kind,
    path = item:text_path(),
  }
end

local function build_items_nodes(items)
  local nodes = {}
  for _, item_data in ipairs(items) do
    local item = state.items[item_data.id]
    if not item then
      vim.notify("No item for id: " .. item_data.id, vim.log.levels.ERROR)
    else
      local node = node_from_item(item)
      if item.items then
        node.children = #item.items > 0 and build_items_nodes(item.items) or {}
        node.loaded = true
        node.expanded = true
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
    local export_node = node_from_item(state.items["export"])
    export_node.children = build_items_nodes(state.items["export"].items)
    export_node.loaded = true
    export_node.expanded = true

    state_param.default_expanded_nodes = { "export", "export_templates", "export_configs", "export_output" }

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
