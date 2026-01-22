local Path = require("plenary.path")

local M = {}

-- Default chapter template (used if no custom template exists)
M.DEFAULT_CHAPTER = "# Chapter {{num}}: {{title}}\n\n"

local function get_app_root()
  local app_root = debug.getinfo(1, "S").source:sub(2):match("(.*/app/)")
  return app_root and (app_root .. "templates/export/") or nil
end

--- Find a template file, checking project first then app defaults
---@param root string Project root path
---@param filename string Template filename (e.g., "epub.css", "reference.docx")
---@return string|nil path Path to template if found
function M.find(root, filename)
  local project_path = root .. "/exports/templates/" .. filename
  if Path:new(project_path):exists() then
    return project_path
  end

  local app_root = get_app_root()
  if app_root then
    local app_path = app_root .. filename
    if Path:new(app_path):exists() then
      return app_path
    end
  end

  return nil
end

--- Load chapter template from project or fall back to app default
---@param root string Project root path
---@return string template The chapter template content
function M.load_chapter(root)
  local project_template = root .. "/exports/templates/chapter.md"
  local loaded = M.load(project_template)
  if loaded then
    return loaded
  end

  local app_root = get_app_root()
  if app_root then
    local default_template = app_root .. "chapter.md"
    loaded = M.load(default_template)
    if loaded then
      return loaded
    end
  end

  return M.DEFAULT_CHAPTER
end

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

return M
