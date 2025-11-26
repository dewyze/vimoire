local Manuscript = {}
local Path = require("plenary.path")

function Manuscript.load(root_path)
  local manuscript_file = Path:new(root_path, "manuscript.json")

  if not manuscript_file:exists() then
    return nil, "manuscript.json not found at " .. root_path
  end

  local content, err = manuscript_file:read()
  if not content then
    return nil, "Failed to read manuscript.json: " .. err
  end

  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    return nil, "Failed to parse manuscript.json: " .. data
  end

  local manuscript = Manuscript.new(data)
  manuscript._root = root_path

  return manuscript
end

function Manuscript.new(data)
  local self = setmetatable(data, { __index = Manuscript })
  return self
end

function Manuscript:save()
  if not self._root then
    return false, "No root path set. Cannot save."
  end

  local manuscript_file = Path:new(self._root, "manuscript.json")

  -- Create a copy without _root for serialization
  local data = {}
  for k, v in pairs(self) do
    if k ~= "_root" then
      data[k] = v
    end
  end

  local json = vim.fn.json_encode(data)

  local ok, err = pcall(function()
    manuscript_file:write(json, "w")
  end)

  if not ok then
    return false, "Failed to save manuscript.json: " .. err
  end

  return true
end

return Manuscript
