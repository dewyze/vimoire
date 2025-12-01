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
      chapter.title,
      "chapter",
      chapter:text_path()
    )
    table.insert(nodes, node)
  end

  return nodes
end

local function build_planning_section(items, folder_id, folder_name, item_type, id_prefix)
  if not items or #items == 0 then
    return nil
  end

  local nodes = {}
  for _, item in ipairs(items) do
    local node = create_node(
      id_prefix .. ":" .. item.id,
      item.name,
      item_type,
      state.manuscript.root .. "/" .. item.file
    )
    table.insert(nodes, node)
  end

  local folder = create_node(folder_id, folder_name, folder_id, nil)
  folder.children = nodes
  return folder
end

local function build_section_nodes(manuscript)
  local nodes = {}

  for _, section in ipairs(manuscript.sections) do
    if section.visible then
      local node = create_node(
        "sec:" .. section.id,
        section.title,
        "section",
        nil
      )
      node.children = build_chapter_nodes(section)
      table.insert(nodes, node)
    end
  end

  return nodes
end

local function build_planning_nodes(manuscript)
  local planning = {}

  local chars = build_planning_section(manuscript.characters, "characters", "Characters", "character", "char")
  local settings = build_planning_section(manuscript.settings, "settings", "Settings", "setting", "set")
  local refs = build_planning_section(manuscript.reference, "reference", "Reference", "reference_file", "ref")

  for _, section in ipairs({ chars, settings, refs }) do
    if section then
      table.insert(planning, section)
    end
  end

  if #planning > 0 then
    local planning_folder = create_node("planning", "Planning", "planning", nil)
    planning_folder.children = planning
    return { planning_folder }
  end

  return {}
end

function M.navigate(state_param, path)
  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(function()
    local manuscript_node = create_node("manuscript", "Manuscript", "manuscript", nil)

    local children = {}

    local section_nodes = build_section_nodes(state.manuscript)
    for _, node in ipairs(section_nodes) do
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
