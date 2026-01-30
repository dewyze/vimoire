local setup = {}
local state = require("vimoire.state")
local recent = require("vimoire.core.recent")
local statusline = require("vimoire.statusline")
local autosave = require("vimoire.autosave")
local focus = require("vimoire.focus")
local comments = require("vimoire.comments")
local plotting = require("vimoire.plotting")
local stats = require("vimoire.stats")

local function refresh_neotree()
  local manager = require("neo-tree.sources.manager")
  manager.refresh("manuscript")
end

local function set_window_title()
  vim.o.title = true
  vim.o.titlestring = "Vimoire — " .. state.book.title
end

function setup.on_manuscript_loaded()
  local Book = require("vimoire.core.book")
  local manuscript_source = require("vimoire.navigation.sources.manuscript")
  manuscript_source.display_name = "󱓷 " .. state.book.title
  recent.add(state.manuscript.root, state.book.title)
  set_window_title()
  statusline.setup()
  autosave.setup()
  focus.setup()
  comments.setup()
  plotting.setup()
  stats.init()

  local augroup = vim.api.nvim_create_augroup("VimoireSetup", { clear = true })

  -- Reload book.yml on save and refresh neotree
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*/book.yml",
    callback = function()
      state.book = Book.load(state.manuscript.root)
      state:rebuild()
      set_window_title()
      manuscript_source.display_name = "󱓷 " .. state.book.title
      refresh_neotree()
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = function(args)
      local item = state.paths[args.file]
      if item then
        vim.b.vimoire_item_id = item.id
        vim.b.vimoire_display_name = item:display_name_for_path(args.file)

        -- Store as last edited for this manuscript
        recent.set_last_edited(state.manuscript.root, item.id)
      end
    end
  })

  vim.schedule(function()
    require("neo-tree.command").execute({ source = "manuscript" })

    -- Restore last edited file for this manuscript
    local item_id = recent.get_last_edited(state.manuscript.root)
    if item_id then
      local item = state.items[item_id]
      if item and item.text_path then
        local open = require("vimoire.navigation.open")
        open.open_item(item)
      end
    end
  end)
end

local function resolve_project_path(path)
  path = vim.fn.fnamemodify(vim.fn.expand(path), ":p"):gsub("/$", "")

  if path:match("manuscript%.json$") then
    path = vim.fn.fnamemodify(path, ":h")
  end

  if vim.fn.filereadable(path .. "/manuscript.json") == 1 then
    return path
  end

  return nil
end

function setup.load_manuscript()
  local args = vim.fn.argv()

  -- Clear args so Neo-tree's hijack_netrw doesn't try to handle them
  if #args > 0 then
    vim.cmd("argdelete *")

    local project_path = resolve_project_path(args[1])
    if project_path then
      state:load(project_path)
      vim.api.nvim_exec_autocmds("User", { pattern = "VimoireProjectLoaded" })
      return
    end
  end

  require("vimoire.ui.dashboard").show()
end

function setup.show_dashboard()
  if state.manuscript then
    require("vimoire.ui.project_dashboard").show()
  else
    require("vimoire.ui.dashboard").show()
  end
end

return setup
