local M = {}

local open_util = require("vimoire.util.open")

M.open_external = open_util.open_external
M.open_file = open_util.open_file

function M.open_item(item)
  local path = item:text_path()
  if not path then return end
  M.open_file(path)
end

return M
