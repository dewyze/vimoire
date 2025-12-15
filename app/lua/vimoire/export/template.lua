local Path = require("plenary.path")

local M = {}

-- Render a template string with {{placeholder}} substitution
-- Missing values are replaced with empty string
function M.render(template_str, context)
  return template_str:gsub("{{([^}]+)}}", function(key)
    local value = context[key]
    if value == nil then
      return ""
    end
    return tostring(value)
  end)
end

-- Load template from file, return nil if not found
function M.load(path)
  local p = Path:new(path)
  if not p:exists() then
    return nil
  end
  return p:read()
end

-- Default chapter template (used if no custom template exists)
M.DEFAULT_CHAPTER = "# Chapter {{num}}: {{title}}\n\n"

return M
