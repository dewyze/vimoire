local Store = require("vimoire.comments.store")
local extmarks = require("vimoire.comments.extmarks")
local ui = require("vimoire.comments.ui")
local Snacks = require("snacks")

local M = {}

local augroup = vim.api.nvim_create_augroup("VimoireComments", { clear = true })

-- Buffer-local state accessor
local function get_state(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.b[bufnr].vimoire_comments
end

local function set_state(bufnr, state)
  vim.b[bufnr].vimoire_comments = state
end

local function get_item_for_buffer(bufnr)
  local item_id = vim.b[bufnr].vimoire_item_id
  if not item_id then
    return nil
  end

  local state = require("vimoire.state")
  return state.items[item_id]
end

-- Initialize comments for a prose buffer
local function init_buffer(bufnr)
  local item = get_item_for_buffer(bufnr)
  if not item then
    return
  end

  local dir_path = item:dir_path()
  local store = Store.new(dir_path)
  local comments = store:load()

  local config = require("vimoire.config")
  local visible = config.get("comments.visible")
  if visible == nil then
    visible = true
  end

  -- Store dir_path instead of store object (vim.b can't hold metatables)
  set_state(bufnr, {
    dir_path = dir_path,
    comments = comments,
    visible = visible,
  })

  extmarks.render(bufnr, comments, visible)
end

-- Save comments when buffer is written
local function save_buffer(bufnr)
  local buf_state = get_state(bufnr)
  if not buf_state or not buf_state.dir_path then
    return
  end

  local comments
  if buf_state.visible then
    -- Collect current extmark positions (they track edits)
    comments = extmarks.collect(bufnr)
    buf_state.comments = comments
    set_state(bufnr, buf_state)
  else
    -- Visibility off means no extmarks - use stored comments
    comments = buf_state.comments
  end

  local store = Store.new(buf_state.dir_path)
  store:save(comments)
end

function M.setup()
  extmarks.setup()

  -- Initialize on prose files
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "vimoire_prose",
    callback = function(args)
      -- Defer to ensure vimoire_item_id is set
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          init_buffer(args.buf)
        end
      end, 10)
    end,
  })

  -- Save on write
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*/entries/*/prose.md",
    callback = function(args)
      save_buffer(args.buf)
    end,
  })

  -- Re-render on colorscheme change (signs are theme-specific)
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local buf_state = get_state(bufnr)
        if buf_state and buf_state.comments then
          extmarks.render(bufnr, buf_state.comments, buf_state.visible)
        end
      end
    end,
  })
end

-- Public API

function M.create(text, start_line, start_col, end_line, end_col)
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_state = get_state(bufnr)
  if not buf_state then
    vim.notify("Not in a prose buffer", vim.log.levels.WARN)
    return
  end

  local existing_ids = Store.id_set(buf_state.comments)
  local comment = Store.create_comment(text, start_line, start_col, end_line, end_col, existing_ids)

  table.insert(buf_state.comments, comment)
  set_state(bufnr, buf_state)
  extmarks.render(bufnr, buf_state.comments, buf_state.visible)

  vim.bo[bufnr].modified = true
end

function M.edit(new_text)
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_state = get_state(bufnr)
  if not buf_state then
    return
  end

  local at_cursor = extmarks.get_at_cursor(bufnr)
  if not at_cursor then
    vim.notify("No comment at cursor", vim.log.levels.WARN)
    return
  end

  for _, comment in ipairs(buf_state.comments) do
    if comment.id == at_cursor.comment_id then
      comment.text = new_text
      break
    end
  end

  set_state(bufnr, buf_state)
  extmarks.render(bufnr, buf_state.comments, buf_state.visible)
  vim.bo[bufnr].modified = true
end

function M.delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_state = get_state(bufnr)
  if not buf_state then
    return
  end

  local at_cursor = extmarks.get_at_cursor(bufnr)
  if not at_cursor then
    vim.notify("No comment at cursor", vim.log.levels.WARN)
    return
  end

  for i, comment in ipairs(buf_state.comments) do
    if comment.id == at_cursor.comment_id then
      table.remove(buf_state.comments, i)
      break
    end
  end

  set_state(bufnr, buf_state)
  extmarks.render(bufnr, buf_state.comments, buf_state.visible)
  vim.bo[bufnr].modified = true
end

function M.view()
  local bufnr = vim.api.nvim_get_current_buf()
  local at_cursor = extmarks.get_at_cursor(bufnr)
  if not at_cursor then
    vim.notify("No comment at cursor", vim.log.levels.WARN)
    return
  end

  ui.show_popup(at_cursor)
end

function M.toggle_visibility()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_state = get_state(bufnr)
  if not buf_state then
    return
  end

  buf_state.visible = not buf_state.visible
  set_state(bufnr, buf_state)
  extmarks.render(bufnr, buf_state.comments, buf_state.visible)

  local status = buf_state.visible and "visible" or "hidden"
  vim.notify("Comments " .. status, vim.log.levels.INFO)
end

function M.next()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local all = extmarks.get_all(bufnr)
  if #all == 0 then
    vim.notify("No comments in buffer", vim.log.levels.INFO)
    return
  end

  -- Find next comment after cursor
  for _, mark in ipairs(all) do
    if mark.start_line > row or (mark.start_line == row and mark.start_col > col) then
      vim.api.nvim_win_set_cursor(0, { mark.start_line + 1, mark.start_col })
      return
    end
  end

  -- Wrap to first comment
  local first = all[1]
  vim.api.nvim_win_set_cursor(0, { first.start_line + 1, first.start_col })
end

function M.prev()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local all = extmarks.get_all(bufnr)
  if #all == 0 then
    vim.notify("No comments in buffer", vim.log.levels.INFO)
    return
  end

  -- Find previous comment before cursor
  for i = #all, 1, -1 do
    local mark = all[i]
    if mark.start_line < row or (mark.start_line == row and mark.start_col < col) then
      vim.api.nvim_win_set_cursor(0, { mark.start_line + 1, mark.start_col })
      return
    end
  end

  -- Wrap to last comment
  local last = all[#all]
  vim.api.nvim_win_set_cursor(0, { last.start_line + 1, last.start_col })
end

function M.list()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_state = get_state(bufnr)
  if not buf_state or #buf_state.comments == 0 then
    vim.notify("No comments in buffer", vim.log.levels.INFO)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local items = {}
  for _, comment in ipairs(buf_state.comments) do
    -- Extract the commented text from the buffer
    local commented_text
    if comment.start_line == comment.end_line then
      local line = lines[comment.start_line + 1] or ""
      commented_text = line:sub(comment.start_col + 1, comment.end_col)
    else
      -- Multi-line: just show first line with ellipsis
      local line = lines[comment.start_line + 1] or ""
      commented_text = line:sub(comment.start_col + 1) .. "..."
    end

    table.insert(items, {
      text = commented_text:gsub("\n", " "):sub(1, 60),
      comment_text = comment.text,
      line = comment.start_line + 1,
      col = comment.start_col,
    })
  end

  Snacks.picker({
    title = "Comments",
    items = items,
    format = function(item)
      return { { string.format("%d: %s", item.line, item.text), "Normal" } }
    end,
    preview = function(ctx)
      local item = ctx.item
      if not item then return end
      local preview_lines = vim.split(item.comment_text, "\n")
      ctx.preview:set_lines(preview_lines)
    end,
    confirm = function(picker, selected)
      if selected then
        picker:close()
        vim.api.nvim_win_set_cursor(0, { selected.line, selected.col })
      end
    end,
  })
end

function M.clear_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_state = get_state(bufnr)
  if not buf_state then
    return
  end

  buf_state.comments = {}
  set_state(bufnr, buf_state)
  extmarks.clear(bufnr)
  vim.bo[bufnr].modified = true
  vim.notify("All comments cleared", vim.log.levels.INFO)
end

-- Get comment at cursor (for commands that need it)
function M.get_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  return extmarks.get_at_cursor(bufnr)
end

return M
