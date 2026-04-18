-- Typewriter scrolling mode
-- Keeps the cursor vertically centered while writing

local M = {}

local config = require("vimoire.config")
local preferences = require("vimoire.preferences")

local PREF_KEY = "typewriter_scrolling"

-- Get effective state: preferences > config > default (false)
function M.is_enabled()
  local pref = preferences.get(PREF_KEY)
  if pref ~= nil then
    return pref
  end
  return config.get("editor.typewriter_scrolling") or false
end

-- Apply scrolloff to a window based on typewriter state
function M.apply(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if M.is_enabled() then
    vim.wo[winid].scrolloff = 999
  else
    vim.wo[winid].scrolloff = config.get("editor.scrolloff") or 5
  end
end

-- Apply to all prose windows
local function apply_to_prose_windows()
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local ft = vim.bo[bufnr].filetype
    if ft == "vimoire_prose" then
      M.apply(winid)
    end
  end
end

-- Toggle typewriter mode and persist
function M.toggle()
  local current = M.is_enabled()
  local new_state = not current
  preferences.set(PREF_KEY, new_state)
  apply_to_prose_windows()

  local status = new_state and "enabled" or "disabled"
  vim.notify("Typewriter mode " .. status, vim.log.levels.INFO)
end

return M
