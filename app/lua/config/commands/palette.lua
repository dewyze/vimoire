-- Commands to show in palette (controls order too)
-- Note: SnippetExtract excluded (visual mode only)
-- Note: Characters/Settings/Reference excluded (use Planning or Navigate)
local COMMANDS = {
  -- Find
  { cmd = "Navigate", display = "Find > All Files" },
  { cmd = "Manuscript", display = "Find > Manuscript" },
  { cmd = "Planning", display = "Find > Planning" },
  { cmd = "Exports", display = "Find > Exports" },
  { cmd = "Snippets", display = "Find > Snippets" },

  -- View
  { cmd = "Home", display = "View > Home" },
  { cmd = "Focus", display = "View > Focus Mode" },
  { cmd = "Theme", display = "View > Theme" },

  -- Writing
  { cmd = "Notes", display = "Writing > Notes" },
  { cmd = "Prose", display = "Writing > Jump to Prose" },
  { cmd = "Marks", display = "Writing > Browse Marks" },
  { cmd = "ToggleKind", display = "Writing > Toggle Chapter/Page" },

  -- Insert
  { cmd = "InsertMark", display = "Insert > Mark" },
  { cmd = "InsertImage", display = "Insert > Image" },

  -- Export
  { cmd = "Export", display = "Export > Run Export" },
  { cmd = "ExportConfig", display = "Export > Generate Config" },
}

local function get_keymap_for_command(cmd_name)
  local keymaps = vim.api.nvim_get_keymap("n")
  for _, km in ipairs(keymaps) do
    if km.rhs and km.rhs:match(":" .. cmd_name .. "<CR>") then
      return km.lhs
    end
  end
  return nil
end

local function build_items()
  local items = {}
  local commands = vim.api.nvim_get_commands({})

  for _, entry in ipairs(COMMANDS) do
    local cmd = commands[entry.cmd]
    if cmd then
      local desc = cmd.definition or ""
      table.insert(items, {
        text = entry.display,
        cmd = entry.cmd,
        keymap = get_keymap_for_command(entry.cmd),
        preview = { text = desc },
      })
    end
  end

  return items
end

vim.api.nvim_create_user_command("Palette", function()
  local Snacks = require("snacks")
  local items = build_items()

  Snacks.picker({
    title = "Commands",
    items = items,
    preview = "preview",
    format = function(item)
      local parts = { { item.text, "Normal" } }
      if item.keymap then
        table.insert(parts, { "  " .. item.keymap, "Comment" })
      end
      return parts
    end,
    confirm = function(picker, selected)
      if selected then
        picker:close()
        vim.cmd(selected.cmd)
      end
    end,
  })
end, { desc = "Open command palette" })
