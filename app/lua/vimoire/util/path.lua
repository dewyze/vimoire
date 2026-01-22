local M = {}

local NAVIGATOR_SOURCES = {
  exports = "export",
}

local function subfolder(filepath, root)
  if not filepath or not root then return nil end
  local relative = filepath:sub(#root + 2)
  return relative:match("^([^/]+)")
end

function M.navigator_source(filepath)
  local state = require("vimoire.state")
  local root = state.manuscript and state.manuscript.root
  return NAVIGATOR_SOURCES[subfolder(filepath, root)] or "manuscript"
end

return M
