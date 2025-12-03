local state = require("vimoire.state")

local M = {
  name = "vimoire",
  display_name = "󱓷 Vimoire",
  default_config = {
    renderers = {
      manuscript = { { "indent" }, { "icon" }, { "name" } },
      section = { { "indent" }, { "icon" }, { "name" } },
      chapter = { { "indent" }, { "icon" }, { "name" } },
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

local function build_chapter_nodes(section)
  local chapters = section.chapters or {}
  local nodes = {}

  for _, chapter in ipairs(chapters) do
    local node = create_node(
      "chap:" .. chapter.id,
      chapter:display_number() .. ": " .. chapter.title,
      "chapter",
      chapter:text_path()
    )
    table.insert(nodes, node)
  end

  return nodes
end

local function build_planning_section(items, folder_id, folder_name, item_type, id_prefix)
  items = items or {}
  local base_path = "planning/" .. folder_id .. "/"
  local subfolders = {}
  local root_items = {}

  -- Group items by subfolder
  for _, item in ipairs(items) do
    local relative = item.file:sub(#base_path + 1)
    local subfolder = relative:match("^(.+)/[^/]+$")

    if subfolder then
      subfolders[subfolder] = subfolders[subfolder] or {}
      table.insert(subfolders[subfolder], item)
    else
      table.insert(root_items, item)
    end
  end

  local nodes = {}

  -- Add root-level items first
  for _, item in ipairs(root_items) do
    local node = create_node(
      id_prefix .. ":" .. item.id,
      item.name,
      item_type,
      state.manuscript.root .. "/" .. item.file
    )
    table.insert(nodes, node)
  end

  -- Add subfolder nodes
  local sorted_subfolders = vim.tbl_keys(subfolders)
  table.sort(sorted_subfolders)

  for _, subfolder_name in ipairs(sorted_subfolders) do
    local subfolder_items = subfolders[subfolder_name]
    local subfolder_label = subfolder_name:sub(1, 1):upper() .. subfolder_name:sub(2)
    local subfolder_node = create_node(
      folder_id .. ":" .. subfolder_name,
      subfolder_label,
      "planning_subfolder",
      nil
    )

    local subfolder_children = {}
    for _, item in ipairs(subfolder_items) do
      local node = create_node(
        id_prefix .. ":" .. item.id,
        item.name,
        item_type,
        state.manuscript.root .. "/" .. item.file
      )
      table.insert(subfolder_children, node)
    end

    subfolder_node.children = subfolder_children
    table.insert(nodes, subfolder_node)
  end

  local folder = create_node(folder_id, folder_name, folder_id, nil)
  folder.children = nodes
  return folder
end

local function build_chapter_group_nodes()
  local nodes = {}

  for _, group in ipairs(state.chapter_groups) do
    if group.section then
      -- Sectioned: wrap chapters in section node (if visible)
      if group.section.visible then
        local section_node = create_node(
          "sec:" .. group.section.id,
          group.section.title,
          "section",
          nil
        )
        section_node.children = build_chapter_nodes(group.section)
        table.insert(nodes, section_node)
      end
    else
      -- Flat: chapters at root level
      for _, chapter in ipairs(group.chapters) do
        local node = create_node(
          "chap:" .. chapter.id,
          chapter:display_number() .. ": " .. chapter.title,
          "chapter",
          chapter:text_path()
        )
        table.insert(nodes, node)
      end
    end
  end

  return nodes
end

local function build_planning_nodes(manuscript)
  local planning_folder = create_node("planning", "Planning", "planning", nil)
  planning_folder.children = {
    build_planning_section(manuscript.characters, "characters", "Characters", "character", "char"),
    build_planning_section(manuscript.settings, "settings", "Settings", "setting", "set"),
    build_planning_section(manuscript.reference, "reference", "Reference", "reference_file", "ref"),
  }
  return { planning_folder }
end

function M.navigate(state_param, path)
  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(function()
    local manuscript_node = create_node("manuscript", "Manuscript", "manuscript", nil)

    local children = {}

    local chapter_nodes = build_chapter_group_nodes()
    for _, node in ipairs(chapter_nodes) do
      table.insert(children, node)
    end

    local planning_nodes = build_planning_nodes(state.manuscript)
    for _, node in ipairs(planning_nodes) do
      table.insert(children, node)
    end

    manuscript_node.children = children

    local renderer = require("neo-tree.ui.renderer")
    renderer.show_nodes({ manuscript_node }, state_param)
  end)

  if not ok then
    vim.notify("navigate error: " .. err, vim.log.levels.ERROR)
  end
end

function M.setup(config, global_config)
  local vimoire_config = require("vimoire.config")
  local colors = vimoire_config.get("navigator.colors")

  vim.api.nvim_set_hl(0, "VimoireManuscript", { fg = colors.manuscript, bold = true })
  vim.api.nvim_set_hl(0, "VimoireSection", { fg = colors.section, bold = true })
  vim.api.nvim_set_hl(0, "VimoireChapter", { fg = colors.chapter })
  vim.api.nvim_set_hl(0, "VimoirePlanning", { fg = colors.planning, bold = true })
  vim.api.nvim_set_hl(0, "VimoirePlanningSubfolder", { fg = colors.planning_subfolder, bold = true })
  vim.api.nvim_set_hl(0, "VimoirePlanningItem", { fg = colors.planning_item })
  vim.api.nvim_set_hl(0, "NeoTreeTabActive", { fg = colors.winbar, bold = true })
end

return M
