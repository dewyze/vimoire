local state = {
  manuscript = nil,
  chapters = nil,
  chapters_by_section = nil,
  sections = nil,
  chapter_groups = nil,
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
  self.chapter_groups = {}

  if not self.manuscript then
    return
  end

  -- Build sections map
  for _, sec_data in ipairs(self.manuscript.sections) do
    local section = Section.new(sec_data)
    self.sections[section.id] = section
    self.chapters_by_section[section.id] = {}
  end

  -- Derive section order from chapter positions (ordered unique)
  local section_order = {}
  local seen = {}
  local unsectioned_chapters = {}

  -- Build chapters and group by section
  local chapter_counts = {}
  local unsectioned_count = 0

  for _, ch_data in ipairs(self.manuscript.chapters) do
    local chapter = Chapter.new(ch_data, self.manuscript.root)
    self.chapters[chapter.id] = chapter

    local section_id = chapter.section
    if section_id and self.sections[section_id] then
      if not seen[section_id] then
        seen[section_id] = true
        table.insert(section_order, section_id)
      end

      chapter_counts[section_id] = (chapter_counts[section_id] or 0) + 1
      chapter.chapter_index = chapter_counts[section_id]
      table.insert(self.chapters_by_section[section_id], chapter)
    else
      unsectioned_count = unsectioned_count + 1
      chapter.chapter_index = unsectioned_count
      table.insert(unsectioned_chapters, chapter)
    end
  end

  -- Set section indices and build chapter_groups
  local sectioned = #section_order > 1
  for i, section_id in ipairs(section_order) do
    local section = self.sections[section_id]
    section.index = i
    section.display_index = sectioned and i or nil
    section.chapters = self.chapters_by_section[section_id]

    for _, chapter in ipairs(section.chapters) do
      chapter.section_index = section.display_index
    end

    table.insert(self.chapter_groups, {
      section = section,
      chapters = section.chapters,
    })
  end

  -- Add unsectioned chapters as a group (if any)
  if #unsectioned_chapters > 0 then
    table.insert(self.chapter_groups, {
      section = nil,
      chapters = unsectioned_chapters,
    })
  end
end

return state
