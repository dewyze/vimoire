local M = {}

local function show(opts)
  local Snacks = require("snacks")
  local vimoire_config = require("vimoire.config")
  local state = require("vimoire.state")
  local open = require("vimoire.navigation.open")

  local preview_enabled = vimoire_config.get("finder.preview")

  Snacks.picker({
    title = opts.title,
    items = vim.tbl_map(function(entry)
      local text = entry.name
      if opts.show_number and entry.display_number and entry.display_number ~= "" then
        text = entry.display_number .. "  " .. entry.name
      end
      return {
        text = text,
        entry = entry,
        file = entry.path,
      }
    end, opts.entries),
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = preview_enabled and "file" or false,
    confirm = function(picker, selected)
      picker:close()
      if not selected then return end
      local entry = selected.entry
      if entry and entry.id then
        local item = state.items[entry.id]
        if item then
          open.open_item(item)
        end
      elseif entry and entry.path then
        open.open_file(entry.path)
      end
    end,
  })
end

function M.manuscript()
  local finder = require("vimoire.finder")
  show({ title = "Manuscript", entries = finder.build_manuscript_entries(), show_number = true })
end

function M.characters()
  local finder = require("vimoire.finder")
  show({ title = "Characters", entries = finder.build_planning_entries("characters") })
end

function M.settings()
  local finder = require("vimoire.finder")
  show({ title = "Settings", entries = finder.build_planning_entries("settings") })
end

function M.reference()
  local finder = require("vimoire.finder")
  show({ title = "Reference", entries = finder.build_planning_entries("reference") })
end

function M.navigate()
  local finder = require("vimoire.finder")
  show({ title = "Navigate", entries = finder.build_all_entries(), show_number = true })
end

function M.planning()
  local finder = require("vimoire.finder")
  show({ title = "Planning", entries = finder.build_all_planning_entries() })
end

function M.exports()
  local finder = require("vimoire.finder")
  show({ title = "Exports", entries = finder.build_exports_entries() })
end

return M
