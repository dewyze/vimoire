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
    local chapter = Chapter.new(ch_data, self.manuscript.root)
    self.chapters[chapter.id] = chapter
  end

  -- Build sections and inverted index
  local sectioned = self.manuscript:sectioned()
  for section_index, sec_data in ipairs(self.manuscript.sections) do
    local section = Section.new(sec_data)
    self.sections[section.id] = section
    section.index = section_index
    section.display_index = sectioned and section_index or nil

    -- chapters_by_section: section_id → [Chapter, Chapter, ...]
    self.chapters_by_section[section.id] = {}
    for chapter_index, chapter_id in ipairs(section.chapter_ids) do
      local chapter = self.chapters[chapter_id]
      chapter.chapter_index = chapter_index
      chapter.section_index = section.display_index
      table.insert(self.chapters_by_section[section.id], chapter)
    end

    -- Store chapters in section for direct access
    section.chapters = self.chapters_by_section[section.id]
  end
end

return state
