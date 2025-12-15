local M = {}

function M.paragraph_breaks(content)
  return content:gsub("%f[\n]\n%f[^\n]", "\n\n")
end

function M.chapter(content, context)
  return content:gsub("{{chapter%.([^}]+)}}", function(key)
    local value = context[key]
    if value then
      return tostring(value)
    end
  end)
end

function M.strip_tags(content)
  local result = content
  result = result:gsub("{{mark:?[^}]*}}\n?", "")
  result = result:gsub("{{todo:?[^}]*}}\n?", "")
  return result
end

function M.book(content, context)
  return content:gsub("{{book%.([^}]+)}}", function(key)
    local value = context[key]
    if value then
      return tostring(value)
    end
  end)
end

return M
