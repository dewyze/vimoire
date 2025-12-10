local Path = require("plenary.path")

local M = {}

local DATA_DIR = vim.fn.expand("~/.local/share/vimoire")
local RECENT_FILE = DATA_DIR .. "/recent.json"
local MAX_RECENT = 10

local function ensure_data_dir()
  local dir = Path:new(DATA_DIR)
  if not dir:exists() then
    dir:mkdir({ parents = true })
  end
end

function M.list()
  local path = Path:new(RECENT_FILE)
  if not path:exists() then
    return {}
  end

  local content = path:read()
  local ok, projects = pcall(vim.json.decode, content)
  if not ok then
    return {}
  end

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
  ensure_data_dir()

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

  -- Write
  local json = vim.json.encode(projects)
  Path:new(RECENT_FILE):write(json, "w")
end

return M
