-- Statusline component functions
local M = {}

local state = require("vimoire.state")
local colors = require("vimoire.statusline.colors")

local SEPARATOR = " › "

-- Cached git branch (refreshed on BufEnter)
local cached_branch = nil

-- Determine context type from item kind and file path
function M.get_context(item, filepath)
  if not item then
    return colors.CONTEXTS.DEFAULT
  end

  local filename = filepath and filepath:match("([^/]+)$") or ""

  -- Notes files for chapters/pages
  if filename == "notes.md" then
    return colors.CONTEXTS.NOTES
  end

  -- Planning items
  if item.kind == "planning_item" or item.kind == "subfolder" then
    return colors.CONTEXTS.PLANNING
  end

  -- Export files
  if item.kind == "export_file" then
    return colors.CONTEXTS.EXPORT
  end

  -- Manuscript entries (chapter, page, section)
  if item.kind == "chapter" or item.kind == "page" or item.kind == "section" then
    return colors.CONTEXTS.PROSE
  end

  return colors.CONTEXTS.DEFAULT
end

-- Build breadcrumb path for an item
-- Returns: "Part 1 › 3: Chapter Name" or "John Smith"
function M.context_path(item, filepath)
  if not item then
    return vim.fn.expand("%:t")
  end

  local display = item:display_name()
  local filename = filepath and filepath:match("([^/]+)$") or ""

  -- Add suffix for notes
  if filename == "notes.md" then
    display = display .. " - Notes"
  end

  -- Add section prefix for manuscript entries
  if item.parent_section then
    display = item.parent_section.name .. SEPARATOR .. display
  end

  return display
end

-- Current buffer word count (for prose files)
function M.word_count()
  local ft = vim.bo.filetype
  if ft ~= "vimoire_prose" and ft ~= "vimoire_markdown" then
    return ""
  end

  local wc = vim.fn.wordcount()
  local words = wc.visual_words or wc.words or 0
  return tostring(words) .. "w"
end

-- Cursor location (line:col)
function M.location()
  local line = vim.fn.line(".")
  local col = vim.fn.virtcol(".")
  return string.format("%d:%d", line, col)
end

-- Git branch name (cached)
function M.branch()
  return cached_branch or ""
end

-- Refresh git branch via git command
function M.refresh_branch()
  local root = state.manuscript and state.manuscript.root
  if not root then
    cached_branch = nil
    return
  end

  local result = vim.fn.system("git -C " .. vim.fn.shellescape(root) .. " branch --show-current 2>/dev/null")
  result = vim.trim(result)

  if vim.v.shell_error ~= 0 or result == "" then
    -- Not a git repo or error - try for detached HEAD
    result = vim.fn.system("git -C " .. vim.fn.shellescape(root) .. " rev-parse --short HEAD 2>/dev/null")
    result = vim.trim(result)
  end

  cached_branch = (vim.v.shell_error == 0 and result ~= "") and result or nil
end

return M
