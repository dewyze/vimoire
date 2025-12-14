local Manuscript = {}
local Path = require("plenary.path")
local json = require("vendor.dkjson")

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
  manuscript.root = root_path

  return manuscript
end

function Manuscript.new(data)
  local self = setmetatable(data, { __index = Manuscript })
  return self
end

-- Key order for consistent JSON output (no more random diffs)
local keyorder = { "id", "created_at", "updated_at", "name", "kind", "items", "characters", "settings", "reference" }

function Manuscript:save()
  if not self.root then
    return false, "No root path set. Cannot save."
  end

  local manuscript_file = Path:new(self.root, "manuscript.json")

  -- Create a copy without root for serialization
  local data = {}
  for k, v in pairs(self) do
    if k ~= "root" then
      data[k] = v
    end
  end

  local encoded = json.encode(data, { keyorder = keyorder })

  local ok, err = pcall(function()
    manuscript_file:write(encoded, "w")
  end)

  if not ok then
    return false, "Failed to save manuscript.json: " .. err
  end

  return true
end

function Manuscript:sectioned()
  local section_count = 0
  for _, item in ipairs(self.items or {}) do
    if item.items then
      section_count = section_count + 1
    end
  end
  return section_count > 1
end

return Manuscript
