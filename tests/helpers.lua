local M = {}

local state = require("vimoire.state")

function M.create_temp_fixture(source_path)
  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")
  vim.fn.system({ "cp", "-r", source_path .. "/.", temp_dir })
  return temp_dir
end

function M.cleanup_temp_fixture(path)
  if path then
    vim.fn.delete(path, "rf")
  end
end

function M.reset_state()
  state.manuscript = nil
  state.entries = nil
  state.sections = nil
  state.entries_by_section = nil
  state.entry_groups = nil
end

return M
