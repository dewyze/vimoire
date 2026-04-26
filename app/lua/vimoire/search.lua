local M = {}

local function item_for_file(state, file)
  return state.paths[vim.fn.fnamemodify(file, ":p")]
end

function M.grep()
  local Snacks = require("snacks")
  local state = require("vimoire.state")
  local config = require("vimoire.config")
  local open_util = require("vimoire.util.open")

  local root = state.manuscript.root

  Snacks.picker.grep({
    title = "Search Manuscript",
    dirs = { root },
    glob = "prose.md",
    preview = config.get("finder.preview") and "file" or false,
    format = function(item, _picker)
      local ret = {}
      local vitem = item_for_file(state, item.file)
      local name = vitem and vitem:display_name() or vim.fn.fnamemodify(item.file, ":h:t")
      ret[#ret + 1] = { name, "SnacksPickerLabel" }
      ret[#ret + 1] = { "  ", "SnacksPickerDelim" }
      if item.line then
        if item.positions then
          local offset = Snacks.picker.highlight.offset(ret)
          Snacks.picker.highlight.matches(ret, item.positions, offset)
        end
        Snacks.picker.highlight.format(item, item.line, ret)
      end
      return ret
    end,
    confirm = function(picker, selected)
      picker:close()
      if not selected or not selected.file then return end
      vim.schedule(function()
        open_util.focus_or_edit(selected.file)
        local vitem = item_for_file(state, selected.file)
        if vitem then
          vim.b.vimoire_item_id = vitem.id
        end
        if selected.pos then
          vim.api.nvim_win_set_cursor(0, { selected.pos[1], math.max(0, selected.pos[2]) })
        end
      end)
    end,
  })
end

return M
