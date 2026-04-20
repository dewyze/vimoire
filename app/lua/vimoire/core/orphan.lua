local Path = require("plenary.path")
local frontmatter = require("vimoire.export.frontmatter")
local entries = require("vimoire.util.entries")

local M = {}

-- Collect all entry IDs from manuscript (recursively walks sections)
local function collect_manifest_ids(items, ids)
  ids = ids or {}
  for _, item in ipairs(items or {}) do
    ids[item.id] = true
    if item.items then
      collect_manifest_ids(item.items, ids)
    end
  end
  return ids
end

-- Collect entry IDs present on disk (folders under entries/ that have a prose.md).
local function collect_disk_ids(root)
  local ids = {}
  for id in entries.each_prose(root) do
    ids[id] = true
  end
  return ids
end

-- Read title from prose.md frontmatter
local function read_title(prose_path)
  local path = Path:new(prose_path)
  if not path:exists() then
    return nil
  end
  local content = path:read()
  local fm, _ = frontmatter.parse(content)
  return fm.title
end

-- Detect and recover orphaned entries
-- Returns list of recovered entry names (for notification)
function M.recover(manuscript)
  local root = manuscript.root
  local manifest_ids = collect_manifest_ids(manuscript.items)
  local disk_ids = collect_disk_ids(root)

  local recovered = {}

  for id, _ in pairs(disk_ids) do
    if not manifest_ids[id] then
      -- Orphan found
      local prose_path = root .. "/entries/" .. id .. "/prose.md"
      local title = read_title(prose_path)
      local name = title or ("Recovered: " .. id)

      local entry_data = {
        id = id,
        name = name,
        kind = "page",
      }

      table.insert(manuscript.items, entry_data)
      table.insert(recovered, name)
    end
  end

  return recovered
end

return M
