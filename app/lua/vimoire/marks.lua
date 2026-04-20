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

function M.browse(bufnr)
  local Snacks = require("snacks")

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")
  local mark_list = M.parse(content)

  if #mark_list == 0 then
    vim.notify("No marks in buffer", vim.log.levels.INFO)
    return
  end

  local picker_items = {}
  for _, mark in ipairs(mark_list) do
    local display = "Line " .. mark.line
    if mark.text then
      display = display .. ": " .. mark.text
    end

    table.insert(picker_items, {
      text = display,
      file = filepath,
      pos = { mark.line, mark.col - 1 },
      mark = mark,
    })
  end

  Snacks.picker({
    title = "Marks",
    items = picker_items,
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    preview = "file",
    confirm = function(picker, selected)
      if selected and selected.mark then
        picker:close()
        vim.api.nvim_win_set_cursor(0, { selected.mark.line, selected.mark.col - 1 })
      end
    end,
  })
end

function M.insert()
  vim.api.nvim_put({ "{{mark:}}" }, "c", true, true)
  -- Search backward for :}} and position after the colon
  vim.fn.search(":}}", "b")
  vim.cmd("normal! l")
  vim.cmd("startinsert")
end

return M
