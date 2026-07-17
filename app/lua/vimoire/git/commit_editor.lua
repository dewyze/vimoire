-- Float editor for intentional milestone commits (:GitCommit). Same pattern
-- as the snippet editor: scratch buffer, <C-s> commits, <Esc> cancels.
local M = {}

function M.open(root)
  local repo = require("vimoire.git.repo")

  local files = repo.files_changed(root)
  local words = repo.word_delta(root)
  local word_sign = words >= 0 and "+" or ""
  local header = string.format(
    "# %d file%s changed · %s%d words\n# <C-s> to commit · <Esc> to cancel\n\n",
    files,
    files ~= 1 and "s" or "",
    word_sign,
    words
  )

  local parent_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "gitcommit"

  local lines = vim.split(header, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Git Commit ",
    title_pos = "center",
    footer = " <C-s> commit | <Esc> cancel ",
    footer_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].cursorline = true

  local function close()
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    if vim.api.nvim_win_is_valid(parent_win) then
      vim.api.nvim_set_current_win(parent_win)
    end
  end

  local function commit()
    local content_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local message_lines = {}
    for _, line in ipairs(content_lines) do
      if not line:match("^#") then
        table.insert(message_lines, line)
      end
    end
    local message = table.concat(message_lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")

    if message == "" then
      vim.notify("Commit message cannot be empty", vim.log.levels.WARN)
      return
    end

    close()

    local ok, err = repo.commit(root, { message = message })
    if ok then
      vim.notify("Committed", vim.log.levels.INFO)
    else
      vim.notify("Commit failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
    end
  end

  local key_opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<Esc>", close, key_opts)
  vim.keymap.set("n", "q", close, key_opts)
  vim.keymap.set({ "n", "i" }, "<C-s>", commit, key_opts)

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = commit,
  })

  -- Cursor on the blank line below the header comments
  vim.api.nvim_win_set_cursor(win, { 3, 0 })
  vim.cmd("startinsert")

  return buf, win
end

return M
