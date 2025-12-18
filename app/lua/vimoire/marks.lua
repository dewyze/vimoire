local M = {}

function M.parse(content)
  local marks = {}
  local line_num = 0

  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    line_num = line_num + 1

    local search_start = 1
    while true do
      local start_pos, end_pos, suffix = line:find("{{mark([^}]*)}}", search_start)

      if not start_pos then
        break
      end

      local text = suffix and suffix:match("^:(.+)") or nil

      table.insert(marks, {
        line = line_num,
        col = start_pos,
        text = text,
      })

      search_start = end_pos + 1
    end
  end

  return marks
end

return M
