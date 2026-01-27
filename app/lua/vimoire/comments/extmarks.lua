local M = {}

local NS_NAME = "vimoire_comments"
local ns_id = nil

-- Map extmark_id -> comment data (per buffer)
-- Structure: { [bufnr] = { [extmark_id] = comment, ... }, ... }
local extmark_data = {}

function M.setup()
  ns_id = vim.api.nvim_create_namespace(NS_NAME)

  vim.api.nvim_set_hl(0, "VimoireComment", { link = "Visual" })
  vim.api.nvim_set_hl(0, "VimoireCommentSign", { link = "DiagnosticInfo" })
end

function M.namespace()
  if not ns_id then
    M.setup()
  end
  return ns_id
end

function M.render(bufnr, comments, visible)
  M.clear(bufnr)

  if not visible or #comments == 0 then
    return
  end

  -- Config overrides theme sign if explicitly set
  local config = require("vimoire.config")
  local config_sign = config.get("comments.sign")
  local sign = config_sign or vim.g.vimoire_comment_sign or "●"

  extmark_data[bufnr] = {}

  for _, comment in ipairs(comments) do
    local ok, extmark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, M.namespace(), comment.start_line, comment.start_col, {
      end_line = comment.end_line,
      end_col = comment.end_col,
      hl_group = "VimoireComment",
      sign_text = sign,
      sign_hl_group = "VimoireCommentSign",
      priority = 100,
    })

    if ok then
      extmark_data[bufnr][extmark_id] = {
        comment_id = comment.id,
        text = comment.text,
        created_at = comment.created_at,
      }
    end
  end
end

function M.clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace(), 0, -1)
  extmark_data[bufnr] = nil
end

function M.get_at_cursor(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local buf_data = extmark_data[bufnr] or {}

  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, M.namespace(), { row, 0 }, { row, -1 }, {
    details = true,
  })

  for _, extmark in ipairs(extmarks) do
    local extmark_id = extmark[1]
    local details = extmark[4]
    local start_col = extmark[3]
    local end_col = details.end_col or start_col
    local data = buf_data[extmark_id]

    if col >= start_col and col <= end_col and data then
      return {
        extmark_id = extmark_id,
        comment_id = data.comment_id,
        text = data.text,
        created_at = data.created_at,
        start_line = extmark[2],
        start_col = start_col,
        end_line = details.end_line or extmark[2],
        end_col = end_col,
      }
    end
  end

  return nil
end

function M.collect(bufnr)
  local buf_data = extmark_data[bufnr] or {}

  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, M.namespace(), 0, -1, {
    details = true,
  })

  local comments = {}
  for _, extmark in ipairs(extmarks) do
    local extmark_id = extmark[1]
    local details = extmark[4]
    local data = buf_data[extmark_id]

    if data then
      table.insert(comments, {
        id = data.comment_id,
        start_line = extmark[2],
        start_col = extmark[3],
        end_line = details.end_line or extmark[2],
        end_col = details.end_col or extmark[3],
        text = data.text,
        created_at = data.created_at,
      })
    end
  end

  return comments
end

function M.get_all(bufnr)
  local buf_data = extmark_data[bufnr] or {}

  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, M.namespace(), 0, -1, {
    details = true,
  })

  local result = {}
  for _, extmark in ipairs(extmarks) do
    local extmark_id = extmark[1]
    local details = extmark[4]
    local data = buf_data[extmark_id]

    if data then
      table.insert(result, {
        extmark_id = extmark_id,
        comment_id = data.comment_id,
        text = data.text,
        start_line = extmark[2],
        start_col = extmark[3],
        end_line = details.end_line or extmark[2],
        end_col = details.end_col or extmark[3],
      })
    end
  end

  return result
end

return M
