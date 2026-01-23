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

  -- Find existing entry to preserve last_edited_item
  local existing_last_edited = nil
  for _, p in ipairs(projects) do
    if p.path == abs_path then
      existing_last_edited = p.last_edited_item
      break
    end
  end

  -- Remove existing entry for this path
  projects = vim.tbl_filter(function(p)
    return p.path ~= abs_path
  end, projects)

  -- Add new entry at the front
  table.insert(projects, 1, {
    path = abs_path,
    title = title,
    last_opened = os.time(),
    last_edited_item = existing_last_edited,
  })

  -- Trim to max
  while #projects > MAX_RECENT do
    table.remove(projects)
  end

  preferences.set("recent_projects", projects)
end

function M.get_last_edited(path)
  local abs_path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  local projects = M.list()
  for _, p in ipairs(projects) do
    if p.path == abs_path then
      return p.last_edited_item
    end
  end
  return nil
end

function M.set_last_edited(path, item_id)
  local abs_path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  local projects = preferences.get("recent_projects") or {}

  for _, p in ipairs(projects) do
    if p.path == abs_path then
      p.last_edited_item = item_id
      preferences.set("recent_projects", projects)
      return
    end
  end
end

return M
