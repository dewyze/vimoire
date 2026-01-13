local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

local M = {}

local SEPARATOR = "------"

function M.dir(root)
  return root .. "/snippets"
end

function M.filepath(root, id)
  return M.dir(root) .. "/" .. id .. ".md"
end

function M.parse(content)
  local lines = vim.split(content, "\n")
  local text_lines = {}
  local description_lines = {}
  local in_description = false

  for _, line in ipairs(lines) do
    if not in_description and line == SEPARATOR then
      in_description = true
    elseif in_description then
      table.insert(description_lines, line)
    else
      table.insert(text_lines, line)
    end
  end

  local text = table.concat(text_lines, "\n"):gsub("%s+$", "")
  local description = table.concat(description_lines, "\n"):gsub("%s+$", "")

  return {
    text = text,
    description = description ~= "" and description or nil,
  }
end

function M.format(text, description)
  local lines = { text, SEPARATOR }
  if description then
    table.insert(lines, description)
  else
    table.insert(lines, "")
  end
  return table.concat(lines, "\n")
end

function M.load(root)
  local dir = Path:new(M.dir(root))
  if not dir:exists() then return {} end

  local snippets = {}
  local files = vim.fn.glob(M.dir(root) .. "/*.md", false, true)

  for _, filepath in ipairs(files) do
    local id = vim.fn.fnamemodify(filepath, ":t:r")
    local content = Path:new(filepath):read()
    local parsed = M.parse(content)

    table.insert(snippets, {
      id = id,
      text = parsed.text,
      description = parsed.description,
    })
  end

  return snippets
end

function M.add(root, text, description)
  local dir = Path:new(M.dir(root))
  if not dir:exists() then
    dir:mkdir({ parents = true })
  end

  local existing_ids = {}
  local files = vim.fn.glob(M.dir(root) .. "/*.md", false, true)
  for _, filepath in ipairs(files) do
    table.insert(existing_ids, vim.fn.fnamemodify(filepath, ":t:r"))
  end

  local id = id_util.generate(existing_ids)
  local filepath = M.filepath(root, id)
  local content = M.format(text, description)

  Path:new(filepath):write(content, "w")

  return { id = id, text = text, description = description }
end

function M.update(root, id, changes)
  local filepath = M.filepath(root, id)
  local path = Path:new(filepath)

  if not path:exists() then return nil end

  local content = path:read()
  local parsed = M.parse(content)

  local updated = {
    id = id,
    text = changes.text or parsed.text,
    description = changes.description ~= nil and changes.description or parsed.description,
  }

  path:write(M.format(updated.text, updated.description), "w")

  return updated
end

function M.remove(root, id)
  local filepath = M.filepath(root, id)
  local path = Path:new(filepath)

  if not path:exists() then return false end

  path:rm()
  return true
end

return M
