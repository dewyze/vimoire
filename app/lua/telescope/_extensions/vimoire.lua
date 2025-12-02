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

local function build_entries()
  local entries = {}
  local root = state.manuscript.root

  -- Add chapters (grouped by section order)
  for _, sec_data in ipairs(state.manuscript.sections) do
    local section = state.sections[sec_data.id]

    -- Add section text.md if it exists
    local section_text_path = Path:new(root, "sections", sec_data.id, "text.md")
    if section_text_path:exists() then
      table.insert(entries, {
        type = "section",
        display_number = "§" .. section.index,
        title = section.title,
        path = section_text_path:absolute(),
      })
    end

    for _, chapter in ipairs(section.chapters) do
      table.insert(entries, {
        type = "chapter",
        display_number = chapter:display_number(),
        title = chapter.title,
        path = chapter:text_path(),
        chapter = chapter,
      })
    end
  end

  -- Add planning docs
  local planning_types = {
    { key = "characters", label = "Characters" },
    { key = "settings", label = "Settings" },
    { key = "reference", label = "Research" },
  }

  for _, ptype in ipairs(planning_types) do
    local items = state.manuscript[ptype.key] or {}
    local base_path = "planning/" .. ptype.key .. "/"

    for _, item in ipairs(items) do
      -- Extract subfolder from path if present
      local relative = item.file:sub(#base_path + 1)
      local subfolder = relative:match("^(.+)/[^/]+$")

      local title
      if subfolder then
        -- Capitalize first letter of subfolder
        local folder_label = subfolder:sub(1, 1):upper() .. subfolder:sub(2)
        title = ptype.label .. " > " .. folder_label .. " > " .. item.name
      else
        title = ptype.label .. " > " .. item.name
      end

      table.insert(entries, {
        type = "planning",
        display_number = "",
        title = title,
        path = Path:new(root, item.file):absolute(),
      })
    end
  end

  return entries
end

local function navigate(opts)
  opts = opts or {}

  local entries = build_entries()

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
      entry.value.title,
    })
  end

  local preview_enabled = vimoire_config.get("finder.preview")
  local previewer = preview_enabled and conf.file_previewer(opts) or false

  -- Enable wrap in preview window
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
    prompt_title = "Navigate",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.display_number .. " " .. entry.title,
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

return telescope.register_extension({
  exports = {
    navigate = navigate,
  },
})
