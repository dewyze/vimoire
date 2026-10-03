-- One calendar day of writing: words added and removed across the book's
-- prose. Net alone hides revision days (write 800, cut 1,200 reads as
-- -400), so both sides are kept.
local WritingDay = {}
WritingDay.__index = WritingDay

function WritingDay.new(day, changes)
  return setmetatable({
    day = day,
    added = changes.added,
    removed = changes.removed,
  }, WritingDay)
end

function WritingDay:net()
  return self.added - self.removed
end

return WritingDay
