local Path = require("plenary.path")
local scandir = require("plenary.scandir")

local M = {}

-- Iterate entries that have a prose.md.
-- Yields (id, prose_path) per entry — id is the directory basename.
function M.each_prose(root)
  local entries_dir = root .. "/entries"
  local dirs = scandir.scan_dir(entries_dir, {
    depth = 1,
    only_dirs = true,
    hidden = true,
    silent = true,
  })
  local i = 0
  return function()
    while true do
      i = i + 1
      local dir = dirs[i]
      if not dir then
        return nil
      end
      local prose_path = dir .. "/prose.md"
      if Path:new(prose_path):exists() then
        return vim.fs.basename(dir), prose_path
      end
    end
  end
end

return M
