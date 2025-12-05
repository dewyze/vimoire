local state = require("vimoire.state")

local M = {
  name = "vimoire",
  display_name = "󱓷 Vimoire",
  default_config = {
    window = {},
    renderers = {
      manuscript = { { "indent" }, { "icon" }, { "name" } },
      section = { { "indent" }, { "icon" }, { "name" } },
      chapter = { { "indent" }, { "icon" }, { "name" } },
      page = { { "indent" }, { "icon" }, { "name" } },
      planning = { { "indent" }, { "icon" }, { "name" } },
      characters = { { "indent" }, { "icon" }, { "name" } },
      character = { { "indent" }, { "icon" }, { "name" } },
      settings = { { "indent" }, { "icon" }, { "name" } },
      setting = { { "indent" }, { "icon" }, { "name" } },
      reference = { { "indent" }, { "icon" }, { "name" } },
      reference_file = { { "indent" }, { "icon" }, { "name" } },
      planning_subfolder = { { "indent" }, { "icon" }, { "name" } },
    },
  },
}

local function create_node(id, name, type, path)
  return {
    id = id,
    name = name,
    type = type,
    path = path,
  }
end

local function build_item_node(item_data, item)
  local node = create_node(
    item_data.id,
    item:display_name(),
    item_data.kind,
    item:text_path()
  )

  if item_data.items then
    node.children = build_items_nodes(item_data.items)
  end

  return node
end

function build_items_nodes(items)
  local nodes = {}
  for _, item_data in ipairs(items) do
    local item = state.items[item_data.id]
    table.insert(nodes, build_item_node(item_data, item))
  end
  return nodes
end

local function build_planning_items(items, item_type)
  local nodes = {}
  for _, item_data in ipairs(items or {}) do
    local item = state.items[item_data.id]
    if item_data.items then
      local node = create_node(item_data.id, item:display_name(), "planning_subfolder", nil)
      node.children = build_planning_items(item_data.items, item_type)
      table.insert(nodes, node)
    else
      local node = create_node(item_data.id, item:display_name(), item_type, item:text_path())
      table.insert(nodes, node)
    end
  end
  return nodes
end

local function build_planning_section(items, folder_id, folder_name, item_type)
  local folder = create_node(folder_id, folder_name, folder_id, nil)
  folder.children = build_planning_items(items, item_type)
  return folder
end

function M.navigate(state_param, path, path_to_reveal, callback)
  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  state_param.path = path or state.manuscript.root

  local ok, err = pcall(function()
    local manuscript_node = create_node("manuscript", "Manuscript", "manuscript", nil)
    manuscript_node.children = build_items_nodes(state.manuscript.items or {})

    local planning_node = create_node("planning", "Planning", "planning", nil)
    planning_node.children = {
      build_planning_section(state.manuscript.characters, "characters", "Characters", "character"),
      build_planning_section(state.manuscript.settings, "settings", "Settings", "setting"),
      build_planning_section(state.manuscript.reference, "reference", "Reference", "reference_file"),
    }

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
