local setup = {}
local state = require("vimoire.state")
local recent = require("vimoire.core.recent")

function setup.on_manuscript_loaded()
  local neotree_source = require("vimoire.navigation.neotree_source")
  neotree_source.display_name = "󱓷 " .. state.book.title
  recent.add(state.manuscript.root, state.book.title)
  vim.o.statusline = "%{get(b:, 'vimoire_display_name', expand('%:t'))}"

  local augroup = vim.api.nvim_create_augroup("VimoireStatusline", { clear = true })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = function(args)
      local item = state.paths[args.file]
      if item then
        vim.b.vimoire_item_id = item.id
        vim.b.vimoire_display_name = item:display_name_for_path(args.file)
      end
    end
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "neo-tree",
    callback = function()
      vim.wo.statusline = " "
    end
  })

  vim.schedule(function()
    require("neo-tree.command").execute({ source = "vimoire" })
  end)
end

function setup.load_manuscript()
  vim.schedule(function()
    local start_screen = require("vimoire.ui.start_screen")
    start_screen.show()
  end)
end

function setup.show_start_screen()
  local start_screen = require("vimoire.ui.start_screen")
  start_screen.show()
end

return setup
