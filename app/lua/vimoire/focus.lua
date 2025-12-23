-- Focus mode for Vimoire
-- Wraps the generic margins module with Vimoire-specific configuration.

local M = {}

local margins = require("margins")
local config = require("vimoire.config")

local function is_neotree_buffer(bufnr)
  return vim.bo[bufnr].filetype == "neo-tree"
end

function M.setup()
  margins.setup({
    content_width = config.get("editor.textwidth") or 80,
    min_margin = 4,
    margin_hl = "Normal",
    should_ignore = is_neotree_buffer,
  })
end

function M.enable()
  margins.enable()
end

function M.disable()
  margins.disable()
end

function M.toggle()
  margins.toggle()
end

function M.redistribute()
  margins.redistribute()
end

function M.is_active()
  return margins.is_active()
end

return M
