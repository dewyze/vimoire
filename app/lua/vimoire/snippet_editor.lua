local snippets = require("vimoire.snippets")

local M = {}

function M.open(opts)
  local root = opts.root
  local snippet_id = opts.snippet_id
  local text = opts.text
  local description = opts.description

  -- For new snippets, create the file first
  if not snippet_id then
    local snippet = snippets.add(root, text or "", description)
    snippet_id = snippet.id
  end

  local filepath = snippets.filepath(root, snippet_id)

  local buf = vim.fn.bufadd(filepath)
  vim.fn.bufload(buf)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.7),
    height = math.floor(vim.o.lines * 0.6),
    col = math.floor(vim.o.columns * 0.15),
    row = math.floor(vim.o.lines * 0.15),
    style = "minimal",
    border = "rounded",
    title = " Snippet ",
    title_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.bo[buf].filetype = "markdown"

  return buf, win
end

return M
