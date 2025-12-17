local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

local M = {}

function M.path(root)
  return root .. "/snippets.json"
end

function M.load(root)
  local filepath = M.path(root)
  local path = Path:new(filepath)
  if not path:exists() then return {} end

  local content = path:read()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return {}
  end

  return data
end

function M.save(root, snippets)
  local filepath = M.path(root)
  local path = Path:new(filepath)
  local json = vim.json.encode(snippets)
  path:write(json, "w")
  return true
end

function M.add(root, text, source_id, source_name)
  local snippets = M.load(root)

  local existing_ids = {}
  for _, s in ipairs(snippets) do
    table.insert(existing_ids, s.id)
  end

  local new_snippet = {
    id = id_util.generate(existing_ids),
    text = text,
    source_id = source_id,
    source_name = source_name,
    created_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  }

  table.insert(snippets, new_snippet)
  M.save(root, snippets)

  return new_snippet
end

function M.remove(root, snippet_id)
  local snippets = M.load(root)

  for i, snippet in ipairs(snippets) do
    if snippet.id == snippet_id then
      table.remove(snippets, i)
      M.save(root, snippets)
      return true
    end
  end

  return false
end

return M
