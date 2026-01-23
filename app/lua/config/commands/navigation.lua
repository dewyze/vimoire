vim.api.nvim_create_user_command("Manuscript", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_manuscript_entries()
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Manuscript",
    items = vim.tbl_map(function(entry)
      return {
        text = (entry.display_number ~= "" and entry.display_number .. "  " or "") .. entry.name,
        entry = entry,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse manuscript" })

vim.api.nvim_create_user_command("Characters", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_planning_entries("characters")
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Characters",
    items = vim.tbl_map(function(entry)
      return {
        text = entry.name,
        entry = entry,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse characters" })

vim.api.nvim_create_user_command("Settings", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_planning_entries("settings")
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Settings",
    items = vim.tbl_map(function(entry)
      return {
        text = entry.name,
        entry = entry,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse settings" })

vim.api.nvim_create_user_command("Reference", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_planning_entries("reference")
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Reference",
    items = vim.tbl_map(function(entry)
      return {
        text = entry.name,
        entry = entry,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse reference" })

vim.api.nvim_create_user_command("Navigate", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_all_entries()
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Navigate",
    items = vim.tbl_map(function(entry)
      return {
        text = (entry.display_number ~= "" and entry.display_number .. "  " or "") .. entry.name,
        entry = entry,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse all entries" })

vim.api.nvim_create_user_command("Planning", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local state = require("vimoire.state")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_all_planning_entries()
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Planning",
    items = vim.tbl_map(function(entry)
      return {
        text = entry.name,
        entry = entry,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.entry.id then
        picker:close()
        local item = state.items[selected.entry.id]
        if item then
          open.open_item(item)
        end
      end
    end,
  })
end, { desc = "Browse planning (characters, settings, reference)" })

vim.api.nvim_create_user_command("Prose", function()
  local state = require("vimoire.state")
  local item_id = vim.b.vimoire_item_id
  if not item_id then return end

  local item = state.items[item_id]
  if not item then return end

  local prose_path = item:text_path()
  if not prose_path then return end

  vim.cmd("edit " .. prose_path)
  vim.b.vimoire_item_id = item.id
end, { desc = "Jump to prose for current entry" })

vim.api.nvim_create_user_command("Exports", function()
  local Snacks = require("snacks")
  local finder = require("vimoire.finder")
  local open = require("vimoire.navigation.open")
  local vimoire_config = require("vimoire.config")

  local entries = finder.build_exports_entries()
  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = "Exports",
    items = vim.tbl_map(function(entry)
      return {
        text = entry.name,
        path = entry.path,
        file = entry.path,
      }
    end, entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      if selected and selected.path then
        picker:close()
        open.open_file(selected.path)
      end
    end,
  })
end, { desc = "Browse exports" })
