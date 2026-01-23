local setup = {}
local state = require("vimoire.state")
local recent = require("vimoire.core.recent")
local statusline = require("vimoire.statusline")
local autosave = require("vimoire.autosave")
local focus = require("vimoire.focus")

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

function setup.load_manuscript()
  vim.schedule(function()
    require("vimoire.ui.dashboard").show()
  end)
end

function setup.show_dashboard()
  require("vimoire.ui.dashboard").show()
end

return setup
