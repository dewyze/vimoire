local M = {}

function M.open(opts)
  local title = opts.title or "Edit"
  local content = opts.content or ""
  local on_save = opts.on_save
  local parent_win = vim.api.nvim_get_current_win()

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"

  -- Set initial content
  local lines = vim.split(content, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Calculate window size
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Open float
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
    footer = " <C-s> save | <Esc> cancel ",
    footer_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].cursorline = true

  -- Track if saved
  local saved = false

  local function close_and_return()
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    if vim.api.nvim_win_is_valid(parent_win) then
      vim.api.nvim_set_current_win(parent_win)
    end
  end

  local function save()
    local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local new_content = table.concat(new_lines, "\n")
    saved = true
    close_and_return()
    if on_save then
      on_save(new_content)
    end
  end

  local function cancel()
    close_and_return()
  end

  -- Keymaps
  local key_opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<Esc>", cancel, key_opts)
  vim.keymap.set("n", "q", cancel, key_opts)
  vim.keymap.set({ "n", "i" }, "<C-s>", save, key_opts)
  vim.keymap.set({ "n", "i" }, "<C-CR>", save, key_opts)

  -- Handle BufWriteCmd for :w
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      save()
    end,
  })

  -- Start in insert mode
  vim.cmd("startinsert")

  return buf, win
end

function M.view(opts)
  local title = opts.title or "View"
  local content = opts.content or ""
  local parent_win = vim.api.nvim_get_current_win()

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false

  -- Set content
  local lines = vim.split(content, "\n", { plain = true })
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Calculate window size
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Open float
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
    footer = " q/Esc close | e edit ",
    footer_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].cursorline = true

  local function close()
    vim.api.nvim_win_close(win, true)
    if vim.api.nvim_win_is_valid(parent_win) then
      vim.api.nvim_set_current_win(parent_win)
    end
  end

  -- Keymaps
  local key_opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<Esc>", close, key_opts)
  vim.keymap.set("n", "q", close, key_opts)

  -- Allow switching to edit mode
  if opts.on_edit then
    vim.keymap.set("n", "e", function()
      close()
      opts.on_edit()
    end, key_opts)
  end

  return buf, win
end

return M
