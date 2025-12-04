local state = {
  manuscript = nil,
  entries = nil,
  entries_by_section = nil,
  sections = nil,
  entry_groups = nil,
}

local Manuscript = require("vimoire.core.manuscript")
local Entry = require("vimoire.core.entry")
local Section = require("vimoire.core.section")

function state:load(manuscript_path)
  self.manuscript = Manuscript.load(manuscript_path)
  self:rebuild()
end

function state:rebuild()
  self.entries = {}
  self.entries_by_section = {}
  self.sections = {}
  self.entry_groups = {}

  if not self.manuscript then
    return
  end

  -- Build sections map
  for i, sec_data in ipairs(self.manuscript.sections) do
    local section = Section.new(sec_data)
    section.index = i
    self.sections[section.id] = section
    self.entries_by_section[section.id] = {}
  end

  -- Track section order from entry positions (first appearance)
  local section_order = {}
  local seen_sections = {}
  local unsectioned_entries = {}

  -- Chapter numbering: count only kind="chapter" entries
  local chapter_count = 0

  -- Build entries and group by section
  for _, entry_data in ipairs(self.manuscript.entries) do
    local entry = Entry.new(entry_data, self.manuscript.root)
    self.entries[entry.id] = entry

    -- Number chapters
    if entry.kind == "chapter" then
      chapter_count = chapter_count + 1
      entry.chapter_index = chapter_count
    end

    local section_id = entry.section
    if section_id and self.sections[section_id] then
      if not seen_sections[section_id] then
        seen_sections[section_id] = true
        table.insert(section_order, section_id)
      end
      table.insert(self.entries_by_section[section_id], entry)
    else
      table.insert(unsectioned_entries, entry)
    end
  end

  -- Set section display indices and build entry_groups
  local sectioned = #section_order > 1
  for i, section_id in ipairs(section_order) do
    local section = self.sections[section_id]
    section.display_index = sectioned and i or nil
    section.entries = self.entries_by_section[section_id]

    -- Set section_index on chapter entries within this section
    for _, entry in ipairs(section.entries) do
      if entry.kind == "chapter" then
        entry.section_index = section.display_index
      end
    end

    table.insert(self.entry_groups, {
      section = section,
      entries = section.entries,
    })
  end

  -- Add unsectioned entries as a group (if any)
  if #unsectioned_entries > 0 then
    table.insert(self.entry_groups, {
      section = nil,
      entries = unsectioned_entries,
    })
  end
end

return state
