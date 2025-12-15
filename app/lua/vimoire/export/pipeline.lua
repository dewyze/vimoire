local preprocess = require("vimoire.export.preprocess")

local M = {}

function M.process_entry(content, context)
  local result = content
  result = preprocess.strip_tags(result)
  result = preprocess.strip_indent(result)
  result = preprocess.chapter(result, context)

  for _, action in ipairs(context.actions or {}) do
    result = action(result, context)
  end

  result = preprocess.paragraph_breaks(result)
  return result
end

function M.process_front_matter(content, book)
  return preprocess.book(content, book)
end

return M
