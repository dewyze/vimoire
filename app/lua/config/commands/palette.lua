-- Commands to show in palette (controls order too)
-- Note: Characters/Settings/Reference excluded (use Planning or Navigate)
local COMMANDS = {
  -- Find
  { cmd = "Navigate", display = "Find > All Files" },
  { cmd = "Manuscript", display = "Find > Manuscript" },
  { cmd = "Planning", display = "Find > Planning" },
  { cmd = "Exports", display = "Find > Exports" },

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
  { cmd = "InsertPageBreak", display = "Insert > Pandoc > Page Break" },
  { cmd = "InsertRule", display = "Insert > Pandoc > Horizontal Rule" },
  { cmd = "InsertDiv", display = "Insert > Pandoc > Fenced Div" },
  { cmd = "InsertComment", display = "Insert > Pandoc > Comment" },

  -- Snippets
  { cmd = "Snippets", display = "Snippets > Browse" },
  { cmd = "SnippetExtract", display = "Snippets > Extract Selection" },

  -- Comments
  { cmd = "CommentCreate", display = "Comments > Create" },
  { cmd = "CommentEdit", display = "Comments > Edit" },
  { cmd = "CommentDelete", display = "Comments > Delete" },
  { cmd = "CommentView", display = "Comments > View" },
  { cmd = "CommentToggle", display = "Comments > Toggle Visibility" },
  { cmd = "CommentList", display = "Comments > List All" },
  { cmd = "CommentNext", display = "Comments > Next" },
  { cmd = "CommentPrev", display = "Comments > Previous" },
  { cmd = "CommentsClear", display = "Comments > Clear All" },

  -- Export
  { cmd = "Export", display = "Export > Run Export" },
  { cmd = "ExportConfig", display = "Export > Generate Config" },
}

local function get_keymap_for_command(cmd_name)
  -- Check both normal and visual mode keymaps
  for _, mode in ipairs({ "n", "v" }) do
    local keymaps = vim.api.nvim_get_keymap(mode)
    for _, km in ipairs(keymaps) do
      if km.rhs and km.rhs:match(":" .. cmd_name .. "<CR>") then
        return km.lhs
      end
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
        vim.schedule(function()
          vim.cmd(selected.cmd)
          vim.cmd("startinsert")
        end)
      end
    end,
    win = {
      input = {
        keys = {
          ["<Esc>"] = { "close", mode = { "n", "i" } },
        },
      },
    },
  })
end, { desc = "Open command palette" })
