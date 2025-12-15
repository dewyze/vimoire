local preprocess = require("vimoire.export.preprocess")
local template = require("vimoire.export.template")

local M = {}

function M.process_entry(content, context, opts)
  opts = opts or {}
  local result = content
  result = preprocess.strip_tags(result)
  result = preprocess.strip_indent(result)
  result = preprocess.chapter(result, context)

  -- Render chapter opening from template if this is a chapter (has num)
  if context.num and opts.chapter_template then
    local fm = opts.frontmatter or {}
    -- Build template context: frontmatter overrides entry context
    local template_context = {
      num = context.num,
      title = fm.title or context.title,
    }
    local opening = template.render(opts.chapter_template, template_context)
    result = opening .. result
  end

  result = preprocess.paragraph_breaks(result)
  return result
end

function M.process_front_matter(content, book)
  return preprocess.book(content, book)
end

return M
