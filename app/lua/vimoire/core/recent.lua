local Path = require("plenary.path")
local preferences = require("vimoire.core.preferences")

local M = {}

local MAX_RECENT = 10

function M.list()
  local projects = preferences.get("recent_projects") or {}

  -- Prune non-existent paths
  local valid = {}
  for _, project in ipairs(projects) do
    local manuscript_path = Path:new(project.path, "manuscript.json")
    if manuscript_path:exists() then
      table.insert(valid, project)
    end
  end

  return valid
end

function M.add(path, title)
  local projects = M.list()
  local abs_path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")

  -- Remove existing entry for this path
  projects = vim.tbl_filter(function(p)
    return p.path ~= abs_path
  end, projects)

  -- Add new entry at the front
  table.insert(projects, 1, {
    path = abs_path,
    title = title,
    last_opened = os.time(),
  })

  -- Trim to max
  while #projects > MAX_RECENT do
    table.remove(projects)
  end

  preferences.set("recent_projects", projects)
end

return M
