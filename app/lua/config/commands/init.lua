-- Load command modules
require("config.commands.export")
require("config.commands.snippets")
require("config.commands.navigation")
require("config.commands.palette")

-- Focus commands
vim.api.nvim_create_user_command("Focus", function()
  require("vimoire.focus").toggle()
end, { desc = "Toggle focus mode (margins)" })

-- Dashboard
vim.api.nvim_create_user_command("Home", function()
  require("neo-tree.command").execute({ action = "close" })
  require("vimoire.setup").show_dashboard()
end, { desc = "Show Vimoire dashboard" })

-- Item commands
vim.api.nvim_create_user_command("Notes", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end

  local item = state.items[item_id]
  if not item then return end

  local notes_path = item:notes_path()
  if not notes_path then return end

  vim.cmd("edit " .. notes_path)
  vim.b.vimoire_item_id = item.id
end, { desc = "Open notes for current chapter/page" })

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

-- Marks
vim.api.nvim_create_user_command("Marks", function()
  local marks = require("vimoire.marks")
  local Snacks = require("snacks")

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  local mark_list = marks.parse(content)

  if #mark_list == 0 then
    vim.notify("No marks in buffer", vim.log.levels.INFO)
    return
  end

  local picker_items = {}
  for _, mark in ipairs(mark_list) do
    local display = "Line " .. mark.line
    if mark.text then
      display = display .. ": " .. mark.text
    end

    table.insert(picker_items, {
      text = display,
      mark = mark,
    })
  end

  Snacks.picker({
    title = "Marks",
    items = picker_items,
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    confirm = function(picker, selected)
      if selected and selected.mark then
        picker:close()
        vim.api.nvim_win_set_cursor(0, { selected.mark.line, selected.mark.col - 1 })
      end
    end,
  })
end, { desc = "Browse marks in current buffer" })

vim.api.nvim_create_user_command("InsertMark", function()
  vim.api.nvim_put({ "{{mark:}}" }, "c", true, true)
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 2 })
  vim.cmd("startinsert")
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
local THEMES = {
  -- Dark
  { name = "inkwell", desc = "Dark — Warm Candlelight" },
  { name = "umbra", desc = "Dark — High Contrast" },
  { name = "abyss", desc = "Dark — Ocean Blues" },
  { name = "hollow", desc = "Dark — Forest Greens" },
  { name = "dusk", desc = "Dark — Twilight Purples" },
  { name = "tempest", desc = "Dark — Storm Grays" },
  { name = "hearth", desc = "Dark — Firelight Reds" },
  { name = "nebula", desc = "Dark — Cosmic Purples" },
  { name = "frost", desc = "Dark — Arctic Blues" },
  -- Light
  { name = "parchment", desc = "Light — Warm Cream" },
  { name = "vellum", desc = "Light — Aged Sepia" },
  { name = "lumen", desc = "Light — High Contrast" },
}

vim.api.nvim_create_user_command("Theme", function()
  local Snacks = require("snacks")
  local original = vim.g.colors_name

  local current_file = vim.api.nvim_buf_get_name(0)
  local items = vim.tbl_map(function(t)
    return {
      text = t.name,
      file = current_file,
      display = t.name:gsub("^%l", string.upper),
      desc = t.desc,
    }
  end, THEMES)

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
        require("vimoire.core.preferences").set("colorscheme", item.text)
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
  local state = require("vimoire.state")
  local images = require("vimoire.images")
  local Snacks = require("snacks")

  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local root = state.manuscript.root

  local function insert_from_file()
    images.browse(function(src_path)
      images.copy_with_collision_handling(root, src_path, function(dest_path)
        if not dest_path then
          return
        end

        local filename = vim.fn.fnamemodify(dest_path, ":t")

        vim.ui.input({ prompt = "Alt text: " }, function(alt_text)
          local md = images.markdown(filename, alt_text or "")
          images.insert_at_cursor(md)
        end)
      end)
    end)
  end

  local function insert_from_assets()
    local image_list = images.list(root)

    if #image_list == 0 then
      vim.notify("No images in assets/images/", vim.log.levels.INFO)
      return
    end

    local picker_items = {}
    for _, filename in ipairs(image_list) do
      table.insert(picker_items, {
        text = filename,
        filename = filename,
        path = images.full_path(root, filename),
      })
    end

    Snacks.picker({
      title = "Images",
      items = picker_items,
      preview = false,
      format = function(item)
        return { { item.text, "Normal" } }
      end,
      actions = {
        delete_image = function(picker)
          local sel = picker:current()
          if sel and sel.filename then
            images.delete(root, sel.filename)
            vim.notify("Deleted " .. sel.filename, vim.log.levels.INFO)
            picker:close()
          end
        end,
        rename_image = function(picker)
          local sel = picker:current()
          if sel and sel.filename then
            vim.ui.input({ prompt = "New filename: ", default = sel.filename }, function(new_name)
              if new_name and new_name ~= "" and new_name ~= sel.filename then
                local ok, err = images.rename(root, sel.filename, new_name)
                if ok then
                  vim.notify("Renamed to " .. new_name, vim.log.levels.INFO)
                else
                  vim.notify(err or "Rename failed", vim.log.levels.ERROR)
                end
              end
              picker:close()
            end)
          end
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-d>"] = { "delete_image", mode = { "n", "i" }, desc = "Delete" },
            ["<C-r>"] = { "rename_image", mode = { "n", "i" }, desc = "Rename" },
          },
          footer_keys = { "<C-d>", "<C-r>" },
        },
      },
      confirm = function(picker, selected)
        if selected and selected.filename then
          picker:close()
          vim.ui.input({ prompt = "Alt text: " }, function(alt_text)
            local md = images.markdown(selected.filename, alt_text or "")
            images.insert_at_cursor(md)
          end)
        end
      end,
    })
  end

  vim.ui.select({ "From file", "From assets" }, {
    prompt = "Insert image:",
  }, function(choice)
    if choice == "From file" then
      insert_from_file()
    elseif choice == "From assets" then
      insert_from_assets()
    end
  end)
end, { desc = "Insert image" })
