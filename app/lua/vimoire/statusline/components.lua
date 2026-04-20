-- Statusline component functions
local M = {}

local state = require("vimoire.state")
local colors = require("vimoire.statusline.colors")
local entries = require("vimoire.util.entries")

local SEPARATOR = " › "

-- Cached book word count (refreshed on save)
local cached_book_word_count = nil

-- Determine context type from item kind and file path
function M.get_context(item, filepath)
  if not item then
    return colors.CONTEXTS.DEFAULT
  end

  local filename = filepath and filepath:match("([^/]+)$") or ""

  -- Notes files always get notes context regardless of item type
  if filename == "notes.md" then
    return colors.CONTEXTS.NOTES
  end

  return item:category()
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

-- Format number with commas
local function format_number(n)
  return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Current buffer word count (for prose files)
-- Returns raw number string, formatted with commas
function M.word_count()
  local ft = vim.bo.filetype
  if ft ~= "vimoire_prose" and ft ~= "vimoire_markdown" then
    return ""
  end

  local wc = vim.fn.wordcount()
  local words = wc.visual_words or wc.words or 0
  return format_number(words)
end

-- Cursor location (line:col)
function M.location()
  local line = vim.fn.line(".")
  local col = vim.fn.virtcol(".")
  return string.format("%d:%d", line, col)
end

-- Book word count (cached, formatted with commas)
-- Returns raw number string
function M.book_word_count()
  if not cached_book_word_count then
    return ""
  end
  return format_number(cached_book_word_count)
end

-- Count words in a file
local function count_file_words(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return 0
  end
  local content = file:read("*a")
  file:close()
  if not content or content == "" then
    return 0
  end
  -- Count words by matching sequences of non-whitespace
  local count = 0
  for _ in content:gmatch("%S+") do
    count = count + 1
  end
  return count
end

-- Refresh book word count by scanning all prose files
function M.refresh_book_word_count()
  local root = state.manuscript and state.manuscript.root
  if not root then
    cached_book_word_count = nil
    return
  end

  local total = 0
  for _, prose_path in entries.each_prose(root) do
    total = total + count_file_words(prose_path)
  end
  cached_book_word_count = total
end

return M
