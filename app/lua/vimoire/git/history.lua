-- Per-day writing derived from the book's commit history. A day's writing is
-- the prose diff from the end of the previous day to the end of this one;
-- today ends at the working tree, so uncommitted words count. Day boundaries
-- are only as sharp as the commits around midnight — the midnight checkpoint
-- in vimoire.git keeps them exact.
local History = {}
History.__index = History

local repo = require("vimoire.git.repo")
local WritingDay = require("vimoire.core.writing_day")

local PROSE = { "entries/*/prose.md" }

-- Local "YYYY-MM-DD" `offset` days from `day`. Noon sidesteps DST shifts.
local function shift(day, offset)
  local year, month, date = day:match("(%d+)-(%d+)-(%d+)")
  return os.date("%Y-%m-%d", os.time({ year = year, month = month, day = date + offset, hour = 12 }))
end

function History.new(root)
  return setmetatable({
    root = root,
    commits = repo.log(root),
    current_day = os.date("%Y-%m-%d"),
  }, History)
end

-- The newest commit on or before `day`, or nil if the history starts later.
function History:tip(day)
  for _, commit in ipairs(self.commits) do
    if commit.day <= day then
      return commit.sha
    end
  end
  return nil
end

function History:day(day)
  local from = self:tip(shift(day, -1))
  if day == self.current_day then
    return WritingDay.new(day, repo.word_changes(self.root, { from = from, paths = PROSE }))
  end

  local to = self:tip(day)
  if to == from then
    return WritingDay.new(day, { added = 0, removed = 0 })
  end
  return WritingDay.new(day, repo.word_changes(self.root, { from = from, to = to, paths = PROSE }))
end

function History:today()
  return self:day(self.current_day)
end

-- The last `count` calendar days, newest first, quiet days included.
function History:days(count)
  local days = {}
  for offset = 0, count - 1 do
    table.insert(days, self:day(shift(self.current_day, -offset)))
  end
  return days
end

return History
