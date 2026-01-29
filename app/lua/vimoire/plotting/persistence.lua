local M = {}

function M.read(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Failed to parse plotting board: " .. path, vim.log.levels.ERROR)
    return nil
  end

  return data
end

function M.write(path, data)
  local content = vim.json.encode(data)

  local file = io.open(path, "w")
  if not file then
    vim.notify("Failed to write plotting board: " .. path, vim.log.levels.ERROR)
    return false
  end

  file:write(content)
  file:close()
  return true
end

return M
