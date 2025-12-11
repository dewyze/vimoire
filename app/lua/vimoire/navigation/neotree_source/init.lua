local state = require("vimoire.state")

local M = {
  name = "vimoire",
  display_name = "󱓷 Vimoire",
  default_config = {
    window = {},
    renderers = {
      manuscript = { { "indent" }, { "icon" }, { "name" } },
      planning = { { "indent" }, { "icon" }, { "name" } },
      characters = { { "indent" }, { "icon" }, { "name" } },
      settings = { { "indent" }, { "icon" }, { "name" } },
      reference = { { "indent" }, { "icon" }, { "name" } },
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

local function build_planning_items(items)
  local nodes = {}
  for _, item_data in ipairs(items or {}) do
    local item = state.items[item_data.id]
    local node = node_from_item(item)
    if item_data.items then
      node.children = #item_data.items > 0 and build_planning_items(item_data.items) or {}
      node.loaded = true
      node.expanded = true
    end
    table.insert(nodes, node)
  end
  return nodes
end

local function build_planning_folder(folder_id)
  local folder = state.items[folder_id]
  local node = node_from_item(folder)
  node.children = build_planning_items(folder.items)
  return node
end

function M.navigate(state_param, path, path_to_reveal, callback)
  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  -- Update source selector display name with manuscript title
  local neotree_config = require("neo-tree.setup").config
  if neotree_config.source_selector and neotree_config.source_selector.sources then
    neotree_config.source_selector.sources[1].display_name = "󱓷 " .. state.manuscript.title
  end

  state_param.path = path or state.manuscript.root

  local ok, err = pcall(function()
    local manuscript_node = node_from_item(state.items["manuscript"])
    local manuscript_children = build_items_nodes(state.manuscript.items or {})
    manuscript_node.children = manuscript_children
    manuscript_node.loaded = true
    manuscript_node.expanded = true

    local planning_node = node_from_item(state.items["planning"])
    local planning_children = build_items_nodes(state.items["planning"].items)
    planning_node.children = planning_children
    planning_node.loaded = true
    planning_node.expanded = true

    -- Set default expanded nodes before rendering (neo-tree uses this, not per-node expanded)
    state_param.default_expanded_nodes = { "manuscript", "planning", "characters", "settings", "reference" }

    local renderer = require("neo-tree.ui.renderer")
    renderer.show_nodes({ manuscript_node, planning_node }, state_param)

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
  local vimoire_config = require("vimoire.config")
  local colors = vimoire_config.get("navigator.colors")

  vim.api.nvim_set_hl(0, "VimoireManuscript", { fg = colors.manuscript, bold = true })
  vim.api.nvim_set_hl(0, "VimoireSection", { fg = colors.section, bold = true })
  vim.api.nvim_set_hl(0, "VimoireChapter", { fg = colors.chapter })
  vim.api.nvim_set_hl(0, "VimoirePage", { fg = colors.page })
  vim.api.nvim_set_hl(0, "VimoirePlanning", { fg = colors.planning, bold = true })
  vim.api.nvim_set_hl(0, "VimoirePlanningSubfolder", { fg = colors.planning_subfolder, bold = true })
  vim.api.nvim_set_hl(0, "VimoirePlanningItem", { fg = colors.planning_item })
  vim.api.nvim_set_hl(0, "NeoTreeTabActive", { fg = colors.winbar, bold = true })
end

return M
