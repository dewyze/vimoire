local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires telescope.nvim")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local state = require("vimoire.state")
local vimoire_config = require("vimoire.config")

local Path = require("plenary.path")

local function build_manuscript_entries()
  local entries = {}

  local function process_items(items)
    for _, item_data in ipairs(items) do
      if item_data.items then
        process_items(item_data.items)
      else
        local item = state.items[item_data.id]
        if item then
          table.insert(entries, {
            display_number = item:display_number() or "",
            name = item.name,
            path = item:text_path(),
          })
        end
      end
    end
  end

  process_items(state.manuscript.items or {})
  return entries
end

local function build_planning_entries(planning_key, label)
  local entries = {}
  local root = state.manuscript.root
  local items = state.manuscript[planning_key] or {}
  local base_path = "planning/" .. planning_key .. "/"

  for _, item in ipairs(items) do
    local relative = item.file:sub(#base_path + 1)
    local subfolder = relative:match("^(.+)/[^/]+$")

    local name
    if subfolder then
      local folder_label = subfolder:sub(1, 1):upper() .. subfolder:sub(2)
      name = folder_label .. " > " .. item.name
    else
      name = item.name
    end

    table.insert(entries, {
      display_number = "",
      name = name,
      path = Path:new(root, item.file):absolute(),
    })
  end

  return entries
end

local function build_all_entries()
  local entries = {}

  for _, entry in ipairs(build_manuscript_entries()) do
    table.insert(entries, entry)
  end

  for _, entry in ipairs(build_planning_entries("characters", "Characters")) do
    entry.name = "Characters > " .. entry.name
    table.insert(entries, entry)
  end

  for _, entry in ipairs(build_planning_entries("settings", "Settings")) do
    entry.name = "Settings > " .. entry.name
    table.insert(entries, entry)
  end

  for _, entry in ipairs(build_planning_entries("reference", "Reference")) do
    entry.name = "Reference > " .. entry.name
    table.insert(entries, entry)
  end

  return entries
end

local function create_picker(title, entries, opts)
  opts = opts or {}

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 6 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.value.display_number, "TelescopeResultsNumber" },
      entry.value.name,
    })
  end

  local preview_enabled = vimoire_config.get("finder.preview")
  local previewer = preview_enabled and conf.file_previewer(opts) or false

  local preview_wrap_group = vim.api.nvim_create_augroup("VimoireTelescopePreview", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = preview_wrap_group,
    pattern = "TelescopePreviewerLoaded",
    callback = function()
      vim.wo.wrap = true
      vim.wo.linebreak = true
    end,
  })

  pickers.new(opts, {
    prompt_title = title,
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.display_number .. " " .. entry.name,
          path = entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection and selection.path then
          vim.cmd("edit " .. selection.path)
        end
      end)
      return true
    end,
  }):find()
end

local function navigate(opts)
  create_picker("Navigate", build_all_entries(), opts)
end

local function manuscript(opts)
  create_picker("Manuscript", build_manuscript_entries(), opts)
end

local function characters(opts)
  create_picker("Characters", build_planning_entries("characters"), opts)
end

local function settings(opts)
  create_picker("Settings", build_planning_entries("settings"), opts)
end

local function reference(opts)
  create_picker("Reference", build_planning_entries("reference"), opts)
end

return telescope.register_extension({
  exports = {
    navigate = navigate,
    manuscript = manuscript,
    characters = characters,
    settings = settings,
    reference = reference,
  },
})
