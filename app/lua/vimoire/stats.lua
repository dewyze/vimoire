-- Writing statistics tracking
local M = {}

local state = require("vimoire.state")

-- Session state
M.session_start_words = nil

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
  local count = 0
  for _ in content:gmatch("%S+") do
    count = count + 1
  end
  return count
end

-- Calculate total book words by scanning all prose files
function M.calculate_book_words()
  local root = state.manuscript and state.manuscript.root
  if not root then
    return 0
  end

  local entries_dir = root .. "/entries"
  local total = 0

  local handle = vim.loop.fs_scandir(entries_dir)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == "directory" then
        local prose_path = entries_dir .. "/" .. name .. "/prose.md"
        total = total + count_file_words(prose_path)
      end
    end
  end

  return total
end

-- Initialize session tracking (call on project load)
function M.init()
  M.session_start_words = M.calculate_book_words()
end

-- Get words written this session
function M.session_words()
  if not M.session_start_words then
    return 0
  end
  return M.calculate_book_words() - M.session_start_words
end

-- Get chapter breakdown with section context
-- Returns: { {id, name, words, section_name}, ... }
function M.chapter_breakdown()
  local root = state.manuscript and state.manuscript.root
  if not root then
    return {}
  end

  local results = {}

  local function process_items(items, section_name)
    for _, item_data in ipairs(items or {}) do
      local item = state.items[item_data.id]
      if not item then
        goto continue
      end

      if item.items then
        -- Section: recurse with section name
        process_items(item.items, item.name)
      else
        -- Entry: count words
        local prose_path = root .. "/entries/" .. item.id .. "/prose.md"
        local words = count_file_words(prose_path)
        table.insert(results, {
          id = item.id,
          name = item:display_name(),
          words = words,
          section_name = section_name,
        })
      end
      ::continue::
    end
  end

  process_items(state.manuscript.items, nil)
  return results
end

-- Get progress toward goal
-- Returns: {current, target, percent} or nil if no goal
function M.progress()
  local book = state.book
  if not book or not book.goals or not book.goals.target_words then
    return nil
  end

  local current = M.calculate_book_words()
  local target = book.goals.target_words
  local percent = math.floor((current / target) * 100)

  return {
    current = current,
    target = target,
    percent = math.min(percent, 100),
  }
end

-- Get daily goal info
-- Returns: {goal, written, percent} or nil if no daily goal
function M.daily_progress()
  local book = state.book
  if not book or not book.goals or not book.goals.daily_words then
    return nil
  end

  local session = M.session_words()
  local goal = book.goals.daily_words
  local percent = math.floor((session / goal) * 100)

  return {
    goal = goal,
    written = session,
    percent = math.min(percent, 100),
  }
end

-- Estimated pages (250 words per page)
function M.estimated_pages()
  return math.floor(M.calculate_book_words() / 250)
end

-- Estimated reading time in minutes
-- Returns: {hours, minutes} or just minutes if under an hour
function M.reading_time()
  local config = require("vimoire.config")
  local wpm = config.get("stats.reading_wpm") or 250
  local words = M.calculate_book_words()
  local total_minutes = math.floor(words / wpm)

  if total_minutes >= 60 then
    local hours = math.floor(total_minutes / 60)
    local minutes = total_minutes % 60
    return { hours = hours, minutes = minutes }
  else
    return { hours = 0, minutes = total_minutes }
  end
end

return M
