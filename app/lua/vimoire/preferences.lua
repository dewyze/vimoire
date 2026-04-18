local Path = require("plenary.path")

local M = {}

local DEFAULT_PREFS_DIR = vim.fn.expand("~/.vimoire")
local _prefs_dir = DEFAULT_PREFS_DIR
local _cache = nil

function M.set_directory(dir)
  _prefs_dir = dir
  _cache = nil
end

function M.reset_directory()
  _prefs_dir = DEFAULT_PREFS_DIR
  _cache = nil
end

local function prefs_file()
  return _prefs_dir .. "/preferences.json"
end

local function ensure_dir()
  local dir = Path:new(_prefs_dir)
  if not dir:exists() then
    dir:mkdir({ parents = true })
  end
end

local function load()
  if _cache then
    return _cache
  end

  local path = Path:new(prefs_file())
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
  Path:new(prefs_file()):write(json, "w")
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
