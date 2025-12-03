local Section = {}
local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

function Section.new(data)
  local self = setmetatable(data, { __index = Section })
  return self
end

function Section.create(state, title)
  -- Generate unique ID
  local existing_ids = {}
  for section_id, _ in pairs(state.sections) do
    table.insert(existing_ids, section_id)
  end
  local new_id = id_util.generate(existing_ids)

  -- Add to manuscript.sections
  local section_data = { id = new_id, title = title, visible = false }
  table.insert(state.manuscript.sections, section_data)

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.sections[new_id]
end

function Section:update(state, attrs)
  local old_visible = self.visible

  -- Update local fields
  for k, v in pairs(attrs) do
    self[k] = v
  end

  -- Update in manuscript.sections
  for _, sec_data in ipairs(state.manuscript.sections) do
    if sec_data.id == self.id then
      for k, v in pairs(attrs) do
        sec_data[k] = v
      end
      break
    end
  end

  -- Manage title page file based on visibility
  if attrs.visible ~= nil and attrs.visible ~= old_visible then
    local section_dir = Path:new(state.manuscript.root, "sections", self.id)
    local title_path = Path:new(section_dir:absolute(), "title.md")

    if attrs.visible then
      section_dir:mkdir({ parents = true })
      title_path:write("# " .. (self.title or "") .. "\n", "w")
    else
      if title_path:exists() then
        vim.fn.delete(title_path:absolute())
      end
    end
  end

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.sections[self.id]
end

function Section:destroy(state)
  -- Remove all chapters belonging to this section
  local chapters_to_remove = {}
  for i, ch_data in ipairs(state.manuscript.chapters) do
    if ch_data.section == self.id then
      table.insert(chapters_to_remove, 1, i) -- insert at front for reverse order
    end
  end

  for _, i in ipairs(chapters_to_remove) do
    local ch_data = state.manuscript.chapters[i]
    -- Delete chapter directory
    local chapter_dir = Path:new(state.manuscript.root, "chapters", ch_data.id)
    if chapter_dir:exists() then
      vim.fn.delete(chapter_dir:absolute(), "rf")
    end
    table.remove(state.manuscript.chapters, i)
  end

  -- Delete section directory if exists
  local section_dir = Path:new(state.manuscript.root, "sections", self.id)
  if section_dir:exists() then
    vim.fn.delete(section_dir:absolute(), "rf")
  end

  -- Remove from manuscript.sections
  for i, sec_data in ipairs(state.manuscript.sections) do
    if sec_data.id == self.id then
      table.remove(state.manuscript.sections, i)
      break
    end
  end

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return true
end

function Section:move(state, position)
  -- Moving a section means moving all its chapters as a block
  -- Section order is derived from chapter order, so we reorder chapters

  -- Extract this section's chapters
  local my_chapters = {}
  local remaining_chapters = {}

  for _, ch_data in ipairs(state.manuscript.chapters) do
    if ch_data.section == self.id then
      table.insert(my_chapters, ch_data)
    else
      table.insert(remaining_chapters, ch_data)
    end
  end

  -- Find where to insert: before position N section's first chapter
  -- Count sections as we go through remaining chapters
  local section_count = 0
  local seen = {}
  local insert_pos = #remaining_chapters + 1

  for i, ch in ipairs(remaining_chapters) do
    if ch.section and not seen[ch.section] then
      seen[ch.section] = true
      section_count = section_count + 1
      if section_count == position then
        insert_pos = i
        break
      end
    end
  end

  -- Rebuild chapters array with our chapters at the right position
  local new_chapters = {}
  for i, ch in ipairs(remaining_chapters) do
    if i == insert_pos then
      for _, my_ch in ipairs(my_chapters) do
        table.insert(new_chapters, my_ch)
      end
    end
    table.insert(new_chapters, ch)
  end

  -- If inserting at end
  if insert_pos > #remaining_chapters then
    for _, my_ch in ipairs(my_chapters) do
      table.insert(new_chapters, my_ch)
    end
  end

  state.manuscript.chapters = new_chapters

  -- Reorder manuscript.sections to match chapter-derived order
  local section_order = {}
  local seen = {}
  for _, ch in ipairs(new_chapters) do
    local sid = ch.section
    if sid and not seen[sid] then
      seen[sid] = true
      table.insert(section_order, sid)
    end
  end

  local sections_by_id = {}
  for _, sec_data in ipairs(state.manuscript.sections) do
    sections_by_id[sec_data.id] = sec_data
  end

  local new_sections = {}
  for _, sid in ipairs(section_order) do
    if sections_by_id[sid] then
      table.insert(new_sections, sections_by_id[sid])
    end
  end
  state.manuscript.sections = new_sections

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.sections[self.id]
end

return Section
