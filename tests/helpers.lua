local M = {}

local state = require("vimoire.state")
local preferences = require("vimoire.preferences")
local Path = require("plenary.path")

-- Use temp directory for preferences during tests
local _prefs_temp_dir = nil

function M.setup_test_preferences()
  _prefs_temp_dir = M.temp_dir()
  preferences.set_directory(_prefs_temp_dir)
end

function M.reset_preferences()
  preferences.reset_directory()
  if _prefs_temp_dir then
    M.cleanup(_prefs_temp_dir)
    _prefs_temp_dir = nil
  end
end

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

function M.reset()
  M.reset_state()
  M.reset_preferences()
end

return M
