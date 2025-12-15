local tinyyaml = require("vendor.tinyyaml")

local M = {}

-- Parse YAML frontmatter from markdown content
-- Returns: frontmatter table (or empty table), body string (without frontmatter)
function M.parse(content)
  if not content or content == "" then
    return {}, ""
  end

  -- Must start with ---
  if not content:match("^%-%-%-\r?\n") then
    return {}, content
  end

  -- Find closing ---
  local _, fm_end = content:find("\n%-%-%-\r?\n", 4)
  if not fm_end then
    -- No closing delimiter, treat as no frontmatter
    return {}, content
  end

  local yaml_text = content:sub(5, fm_end - 4) -- Skip opening "---\n" and closing "\n---"
  local body = content:sub(fm_end + 1)

  -- Parse YAML
  local ok, frontmatter = pcall(tinyyaml.parse, yaml_text)
  if not ok or type(frontmatter) ~= "table" then
    -- Invalid YAML, return empty frontmatter but still strip the block
    return {}, body
  end

  return frontmatter, body
end

return M
