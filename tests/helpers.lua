local M = {}

local state = require("vimoire.state")
local Path = require("plenary.path")

function M.temp_dir()
  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")
  return temp_dir
end

function M.temp_copy(source_path)
  local temp_dir = M.temp_dir()
  vim.fn.system({ "cp", "-r", source_path .. "/.", temp_dir })
  return temp_dir
end

function M.cleanup(path)
  if path then
    vim.fn.delete(path, "rf")
  end
end

function M.write_file(file_path, content)
  local path = Path:new(file_path)
  path:parent():mkdir({ parents = true })
  path:write(content, "w")
end

function M.read_file(file_path)
  local path = Path:new(file_path)
  return path:read()
end

function M.reset_state()
  state.manuscript = nil
  state.items = {}
end

return M
