local state = {
  manuscript = nil,
  chapters = nil,
  chapters_by_section = nil,
  sections = nil
}

local Manuscript = require("vimoire.core.manuscript")
local Chapter = require("vimoire.core.chapter")
local Section = require("vimoire.core.section")

function state:load(manuscript_path)
  self.manuscript = Manuscript.load(manuscript_path)
  self:rebuild()
end

function state:rebuild()
  self.chapters = {}
  self.chapters_by_section = {}
  self.sections = {}

  if not self.manuscript then
    return
  end

  -- Build chapters map
  for _, ch_data in ipairs(self.manuscript.chapters) do
    local chapter = Chapter.new(ch_data)
    self.chapters[chapter.id] = chapter
  end

  -- Build sections and inverted index
  for _, sec_data in ipairs(self.manuscript.sections) do
    local section = Section.new(sec_data, self.manuscript._root)
    self.sections[section.id] = section

    -- chapters_by_section: section_id → [Chapter, Chapter, ...]
    self.chapters_by_section[section.id] = {}
    for _, chapter_id in ipairs(section.chapter_ids) do
      table.insert(self.chapters_by_section[section.id], self.chapters[chapter_id])
    end
  end
end

return state
