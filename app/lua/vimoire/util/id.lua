local M = {}

local CHARSET = "abcdefghijklmnopqrstuvwxyz0123456789"
local ID_LENGTH = 6

local function random_id()
  local result = {}
  for _ = 1, ID_LENGTH do
    local idx = math.random(1, #CHARSET)
    table.insert(result, CHARSET:sub(idx, idx))
  end
  return table.concat(result)
end

function M.generate(existing_set)
  existing_set = existing_set or {}
  local result
  repeat
    result = random_id()
  until not existing_set[result]
  return result
end

return M
