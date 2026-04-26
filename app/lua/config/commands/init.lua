-- Load command modules
require("config.commands.export")
require("config.commands.snippets")
require("config.commands.navigation")
require("config.commands.palette")

-- Focus commands
vim.api.nvim_create_user_command("ViewFocus", function()
  require("vimoire.focus").toggle()
end, { desc = "Toggle focus mode (margins)" })

-- Typewriter mode
vim.api.nvim_create_user_command("ViewTypewriter", function()
  require("vimoire.typewriter").toggle()
end, { desc = "Toggle typewriter mode" })

-- Dashboard
vim.api.nvim_create_user_command("ViewHome", function()
  require("neo-tree.command").execute({ action = "close" })
  require("vimoire.setup").show_dashboard()
end, { desc = "Show Vimoire dashboard" })

vim.api.nvim_create_user_command("ViewProjects", function()
  require("neo-tree.command").execute({ action = "close" })
  require("vimoire.ui.dashboard").show()
end, { desc = "Show project picker (start screen)" })

-- Navigator (side-panel tree views)
vim.api.nvim_create_user_command("NavigateManuscript", function()
  vim.cmd("Neotree source=manuscript")
end, { desc = "Open manuscript tree in side panel" })

vim.api.nvim_create_user_command("NavigateExport", function()
  vim.cmd("Neotree source=export")
end, { desc = "Open export tree in side panel" })

-- Stats
vim.api.nvim_create_user_command("ViewStats", function()
  require("vimoire.ui.stats_window").show()
end, { desc = "Show book statistics" })

-- Item commands
vim.api.nvim_create_user_command("OpenNotes", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end

  local item = state.items[item_id]
  if not item then return end

  if item.open_notes then item:open_notes() end
end, { desc = "Open notes for current chapter/page" })

vim.api.nvim_create_user_command("DeleteNotes", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end
  local item = state.items[item_id]
  if not item then return end
  if not item.delete_notes then return end

  local notes = item:notes_path()
  if not notes or not require("plenary.path"):new(notes):exists() then return end

  local choice = vim.fn.confirm("Delete notes for " .. item:display_name() .. "?", "&Yes\n&No", 2)
  if choice == 1 then
    local prose = item:text_path()
    if prose then vim.cmd("edit " .. prose) end
    item:delete_notes()
    require("neo-tree.sources.manager").refresh("manuscript")
  end
end, { desc = "Delete notes for current chapter/page" })

vim.api.nvim_create_user_command("ToggleKind", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end

  local item = state.items[item_id]
  if not item then return end

  local ok, err = item:toggle(state)
  if ok then
    local manager = require("neo-tree.sources.manager")
    manager.refresh("manuscript")
  else
    vim.notify(err, vim.log.levels.WARN)
  end
end, { desc = "Toggle chapter/page for current buffer" })

-- Search
vim.api.nvim_create_user_command("FileGrep", function()
  require("vimoire.search").grep()
end, { desc = "Search manuscript prose files" })

-- Marks
vim.api.nvim_create_user_command("FindMarks", function()
  require("vimoire.marks").browse(vim.api.nvim_get_current_buf())
end, { desc = "Browse marks in current buffer" })

vim.api.nvim_create_user_command("InsertMark", function()
  require("vimoire.marks").insert()
end, { desc = "Insert mark at cursor" })

vim.api.nvim_create_user_command("InsertPageBreak", function()
  vim.api.nvim_put({ "\\newpage" }, "c", true, true)
end, { desc = "Force a page break in PDF/DOCX output" })

vim.api.nvim_create_user_command("InsertRule", function()
  vim.api.nvim_put({ "---" }, "c", true, true)
end, { desc = "Insert a thematic break or scene separator" })

vim.api.nvim_create_user_command("InsertDiv", function()
  vim.api.nvim_put({ "::: classname", "" , ":::" }, "c", true, true)
end, { desc = "Wrap content in a fenced div for custom styling" })

vim.api.nvim_create_user_command("InsertComment", function()
  vim.api.nvim_put({ "<!--  -->" }, "c", true, true)
end, { desc = "Insert a comment that won't appear in output" })

-- Theme
vim.api.nvim_create_user_command("ViewTheme", function()
  local Snacks = require("snacks")
  local themes = require("vimoire.themes")
  local original = vim.g.colors_name

  local current_file = vim.api.nvim_buf_get_name(0)
  local items = vim.tbl_map(function(t)
    return {
      text = t.name,
      file = current_file,
      display = t.name:gsub("^%l", string.upper),
      desc = t.desc,
    }
  end, themes.list)

  Snacks.picker({
    title = "Theme",
    items = items,
    format = function(item)
      return {
        { item.display, "Normal" },
        { "  " },
        { item.desc, "Comment" },
      }
    end,
    preview = "colorscheme",
    preset = "vertical",
    on_close = function(picker)
      -- Restore original if cancelled (no selection made)
      if picker.preview.state.colorscheme and original then
        vim.cmd.colorscheme(original)
      end
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        picker.preview.state.colorscheme = nil
        vim.cmd.colorscheme(item.text)
        require("vimoire.preferences").set("colorscheme", item.text)
      end
    end,
  })
end, { desc = "Select and save Vimoire colorscheme" })

-- Comments
local comments = require("vimoire.comments")

vim.api.nvim_create_user_command("CommentCreate", function(opts)
  local start_line, start_col, end_line, end_col
  if opts.range == 2 then
    start_line = opts.line1 - 1
    end_line = opts.line2 - 1
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    start_col = start_pos[3] - 1
    end_col = end_pos[3]
  else
    local cursor = vim.api.nvim_win_get_cursor(0)
    start_line = cursor[1] - 1
    start_col = 0
    end_line = start_line
    end_col = #vim.api.nvim_get_current_line()
  end

  vim.ui.input({ prompt = "Comment: " }, function(text)
    if text and text ~= "" then
      comments.create(text, start_line, start_col, end_line, end_col)
    end
  end)
end, { range = true, desc = "Create comment at selection or line" })

vim.api.nvim_create_user_command("CommentEdit", function()
  local at_cursor = comments.get_at_cursor()
  if not at_cursor then
    vim.notify("No comment at cursor", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "Comment: ", default = at_cursor.text }, function(text)
    if text and text ~= "" then
      comments.edit(text)
    end
  end)
end, { desc = "Edit comment at cursor" })

vim.api.nvim_create_user_command("CommentDelete", function()
  comments.delete()
end, { desc = "Delete comment at cursor" })

vim.api.nvim_create_user_command("CommentView", function()
  comments.view()
end, { desc = "View comment at cursor" })

vim.api.nvim_create_user_command("CommentToggle", function()
  comments.toggle_visibility()
end, { desc = "Toggle comment visibility" })

vim.api.nvim_create_user_command("CommentNext", function()
  comments.next()
end, { desc = "Jump to next comment" })

vim.api.nvim_create_user_command("CommentPrev", function()
  comments.prev()
end, { desc = "Jump to previous comment" })

vim.api.nvim_create_user_command("CommentList", function()
  comments.list()
end, { desc = "List comments in buffer" })

vim.api.nvim_create_user_command("CommentsClear", function()
  comments.clear_all()
end, { desc = "Clear all comments in buffer" })

-- Images
vim.api.nvim_create_user_command("InsertImage", function()
  require("vimoire.images").insert()
end, { desc = "Insert image" })
