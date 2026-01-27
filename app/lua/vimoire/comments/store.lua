local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

local Store = {}
Store.__index = Store

local FILENAME = "comments.json"
local VERSION = 1

function Store.new(dir_path)
  local self = setmetatable({}, Store)
  self.dir_path = dir_path
  self.path = dir_path .. "/" .. FILENAME
  return self
end

function Store:load()
  local file = Path:new(self.path)
  if not file:exists() then
    return {}
  end

  local content = file:read()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return {}
  end

  return data.comments or {}
end

function Store:save(comments)
  local data = {
    version = VERSION,
    comments = comments,
  }

  local file = Path:new(self.path)
  file:write(vim.json.encode(data), "w")
end

function Store:exists()
  return Path:new(self.path):exists()
end

-- Create a new comment with generated ID
function Store.create_comment(text, start_line, start_col, end_line, end_col, existing_ids)
  return {
    id = id_util.generate(existing_ids or {}),
    start_line = start_line,
    start_col = start_col,
    end_line = end_line,
    end_col = end_col,
    text = text,
    created_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  }
end

-- Build a set of existing IDs from a comment list
function Store.id_set(comments)
  local set = {}
  for _, comment in ipairs(comments) do
    set[comment.id] = true
  end
  return set
end

return Store
