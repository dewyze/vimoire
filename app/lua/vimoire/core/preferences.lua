local Path = require("plenary.path")

local M = {}

local PREFS_DIR = vim.fn.expand("~/.vimoire")
local PREFS_FILE = PREFS_DIR .. "/preferences.json"

local _cache = nil

local function ensure_dir()
  local dir = Path:new(PREFS_DIR)
  if not dir:exists() then
    dir:mkdir({ parents = true })
  end
end

local function load()
  if _cache then
    return _cache
  end

  local path = Path:new(PREFS_FILE)
  if not path:exists() then
    _cache = {}
    return _cache
  end

  local content = path:read()
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    _cache = {}
    return _cache
  end

  _cache = data
  return _cache
end

local function save(data)
  ensure_dir()
  local json = vim.json.encode(data)
  Path:new(PREFS_FILE):write(json, "w")
  _cache = data
end

function M.get(key)
  local data = load()
  return data[key]
end

function M.set(key, value)
  local data = load()
  data[key] = value
  save(data)
end

return M
