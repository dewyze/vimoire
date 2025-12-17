local state = require("vimoire.state")

local M = {
  name = "manuscript",
  display_name = "󱓷 Manuscript",
  default_config = {
    window = {},
    renderers = {
      book = { { "indent" }, { "icon" }, { "name" } },
      manuscript = { { "indent" }, { "icon" }, { "name" } },
      planning = { { "indent" }, { "icon" }, { "name" } },
      characters = { { "indent" }, { "icon" }, { "name" } },
      settings = { { "indent" }, { "icon" }, { "name" } },
      reference = { { "indent" }, { "icon" }, { "name" } },
      orphaned_notes = { { "indent" }, { "icon" }, { "name" } },
      section = { { "indent" }, { "icon" }, { "name" } },
      chapter = { { "indent" }, { "icon" }, { "name" } },
      page = { { "indent" }, { "icon" }, { "name" } },
      planning_item = { { "indent" }, { "icon" }, { "name" } },
      subfolder = { { "indent" }, { "icon" }, { "name" } },
    },
  },
}

local function node_from_item(item)
  return {
    id = item.id,
    name = item:display_name(),
    type = item.kind,
    path = item:text_path(),
    extra = item.action and { action = function() item:action() end } or nil,
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
    local book_node = node_from_item(state.items["book"])

    local manuscript_node = node_from_item(state.items["manuscript"])
    manuscript_node.children = build_items_nodes(state.manuscript.items or {})
    manuscript_node.loaded = true
    manuscript_node.expanded = true

    local planning_node = node_from_item(state.items["planning"])
    planning_node.children = build_items_nodes(state.items["planning"].items)
    planning_node.loaded = true
    planning_node.expanded = true

    state_param.default_expanded_nodes = { "manuscript", "planning", "characters", "settings", "reference" }

    local renderer = require("neo-tree.ui.renderer")
    renderer.show_nodes({ book_node, manuscript_node, planning_node }, state_param)

    if path_to_reveal then
      local root = state.manuscript.root
      local entry_id = path_to_reveal:match(root .. "/entries/([^/]+)/")
      if entry_id then
        renderer.focus_node(state_param, entry_id)
      end
    end
  end)

  if not ok then
    vim.notify("navigate error: " .. err, vim.log.levels.ERROR)
  end

  if callback then
    callback()
  end
end

function M.setup(config, global_config)
  -- Highlights defined in vimoire/highlights.lua (fallbacks)
  -- and overridden by colorschemes in colors/*.lua
end

return M
