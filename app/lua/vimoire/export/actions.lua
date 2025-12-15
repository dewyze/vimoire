local M = {}

function M.inject_title(content, context)
  if not context.title then
    return content
  end
  return "# " .. context.title .. "\n\n" .. content
end

return M
