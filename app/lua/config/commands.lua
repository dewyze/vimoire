vim.api.nvim_create_user_command("VimoireFocus", function()
  require("vimoire.focus").toggle()
end, { desc = "Toggle focus mode (margins)" })

vim.api.nvim_create_user_command("VimoireHome", function()
  require("neo-tree.command").execute({ action = "close" })
  require("vimoire.setup").show_dashboard()
end, { desc = "Show Vimoire dashboard" })

vim.api.nvim_create_user_command("VimoireNotes", function()
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

vim.api.nvim_create_user_command("VimoireToggleKind", function()
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

vim.api.nvim_create_user_command("VimoireSnippets", function()
  local state = require("vimoire.state")
  local snippets = require("vimoire.snippets")
  local Snacks = require("snacks")

  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local root = state.manuscript.root
  local snippet_list = snippets.load(root)
  if #snippet_list == 0 then
    vim.notify("No snippets", vim.log.levels.INFO)
    return
  end

  local function truncate(text, max_len)
    local first_line = text:match("^([^\n]*)")
    if #first_line > max_len then
      return first_line:sub(1, max_len - 3) .. "..."
    end
    return first_line
  end

  local function format_date(iso_date)
    if not iso_date then return nil end
    local y, m, d = iso_date:match("^(%d+)-(%d+)-(%d+)")
    if not y then return nil end
    local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
    return months[tonumber(m)] .. " " .. tonumber(d) .. ", " .. y
  end

  local picker_items = {}
  for _, snippet in ipairs(snippet_list) do
    local footer_parts = {}
    if snippet.source_name then
      table.insert(footer_parts, "From: " .. snippet.source_name)
    end
    local date_str = format_date(snippet.created_at)
    if date_str then
      table.insert(footer_parts, date_str)
    end
    local footer = #footer_parts > 0 and ("\n\n---\n\n" .. table.concat(footer_parts, " | ")) or ""

    table.insert(picker_items, {
      text = truncate(snippet.text, 50),
      snippet = snippet,
      preview_text = snippet.text .. footer,
    })
  end

  Snacks.picker({
    title = "Snippets",
    items = picker_items,
    preview = function(ctx)
      if ctx.item and ctx.item.preview_text then
        local lines = vim.split(ctx.item.preview_text, "\n")
        vim.bo[ctx.buf].modifiable = true
        vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)
        vim.bo[ctx.buf].modifiable = false
        vim.bo[ctx.buf].filetype = "markdown"
        vim.wo[ctx.win].wrap = true
        vim.wo[ctx.win].linebreak = true
        vim.wo[ctx.win].list = false
      end
      return true
    end,
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    actions = {
      delete_snippet = function(picker)
        local sel = picker:current()
        if sel and sel.snippet then
          snippets.remove(root, sel.snippet.id)
          vim.notify("Snippet deleted", vim.log.levels.INFO)
          picker:close()
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-d>"] = { "delete_snippet", mode = { "n", "i" }, desc = "Delete snippet" },
        },
      },
    },
    confirm = function(picker, selected)
      if selected and selected.snippet then
        local text = selected.snippet.text
        vim.fn.setreg('"', text)
        snippets.remove(root, selected.snippet.id)
        picker:close()
        local lines = vim.split(text, "\n")
        vim.api.nvim_put(lines, "c", true, true)
      end
    end,
  })
end, { desc = "Browse snippets" })

vim.api.nvim_create_user_command("VimoireMarks", function()
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

vim.api.nvim_create_user_command("VimoireSnippetExtract", function()
  local state = require("vimoire.state")
  local snippets = require("vimoire.snippets")

  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local item_id = vim.b.vimoire_item_id
  local item = item_id and state.items[item_id]
  local source_id = item and item.id or nil
  local source_name = item and item:display_name() or nil

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(
    0,
    start_pos[2] - 1,
    start_pos[3] - 1,
    end_pos[2] - 1,
    end_pos[3],
    {}
  )
  local text = table.concat(lines, "\n")

  if text == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  vim.cmd("normal! gvd")
  snippets.add(state.manuscript.root, text, source_id, source_name)
  vim.notify("Snippet saved", vim.log.levels.INFO)
end, { range = true, desc = "Extract selection as snippet" })

local THEMES = {
  "vimoire-inkwell",
  "vimoire-parchment",
  "vimoire-vellum",
  "vimoire-umbra",
  "vimoire-lumen",
}

vim.api.nvim_create_user_command("VimoireTheme", function()
  vim.ui.select(THEMES, {
    prompt = "Select theme:",
    snacks = { layout = { hidden = { "input" }, preview = false } },
  }, function(choice)
    if not choice then return end

    vim.cmd.colorscheme(choice)
    require("vimoire.core.preferences").set("colorscheme", choice)
  end)
end, { desc = "Select and save Vimoire colorscheme" })

vim.api.nvim_create_user_command("VimoireExportConfig", function(opts)
  local state = require("vimoire.state")
  local config = require("vimoire.export.config")
  local Path = require("plenary.path")

  local name = opts.args ~= "" and opts.args or "default"
  local root = state.manuscript.root
  local config_dir = root .. "/exports/configs"
  local config_path = config_dir .. "/" .. name .. ".yml"

  vim.fn.mkdir(config_dir, "p")

  local yaml
  local path = Path:new(config_path)
  if path:exists() then
    local existing = path:read()
    yaml = config.update(state, existing)
  else
    yaml = config.generate(state)
  end

  path:write(yaml, "w")
  state:load(root)
  vim.cmd("edit " .. config_path)
end, { nargs = "?", desc = "Generate or update export config" })

local function open_file(path)
  if vim.ui.open then
    vim.ui.open(path)
  elseif vim.fn.has("mac") == 1 then
    vim.fn.system({ "open", path })
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system({ "xdg-open", path })
  end
end

vim.api.nvim_create_user_command("VimoireInsertImage", function()
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
            ["<C-d>"] = { "delete_image", mode = { "n", "i" }, desc = "Delete image" },
            ["<C-r>"] = { "rename_image", mode = { "n", "i" }, desc = "Rename image" },
          },
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

vim.api.nvim_create_user_command("VimoireExport", function(opts)
  local state = require("vimoire.state")
  local export = require("vimoire.export")
  local config_mod = require("vimoire.config")
  local Path = require("plenary.path")

  -- Parse args: [config_name] [--no-open]
  local args = vim.split(opts.args, "%s+", { trimempty = true })
  local name = "default"
  local no_open = false

  for _, arg in ipairs(args) do
    if arg == "--no-open" then
      no_open = true
    elseif not arg:match("^%-%-") then
      name = arg
    end
  end

  local config_path = state.manuscript.root .. "/exports/configs/" .. name .. ".yml"

  if not Path:new(config_path):exists() then
    vim.notify("Config not found. Run :VimoireExportConfig " .. name .. " first", vim.log.levels.ERROR)
    return
  end

  vim.notify("Exporting...", vim.log.levels.INFO)

  local result = export.run_with_config(state, config_path)

  if result.success then
    vim.notify("Export complete: " .. result.output_path, vim.log.levels.INFO)

    -- Auto-open unless disabled
    local auto_open = config_mod.get("export.auto_open")
    if auto_open and not no_open then
      open_file(result.output_path)
    end
  else
    local msg = "Export failed"
    if result.log_path then
      msg = msg .. ". See " .. result.log_path
    else
      msg = msg .. ": " .. result.error
    end
    vim.notify(msg, vim.log.levels.ERROR)
  end
end, { nargs = "*", desc = "Run export with config" })
