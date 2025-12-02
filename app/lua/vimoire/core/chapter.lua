local Chapter = {}
local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

function Chapter.new(data, root)
  local self = setmetatable(data, { __index = Chapter })
  self.root = root
  return self
end

function Chapter.create(state, section_id, title)
  local section = state.sections[section_id]
  if not section then
    return nil, "Section not found: " .. section_id
  end

  -- Generate unique ID
  local existing_ids = {}
  for chapter_id, _ in pairs(state.chapters) do
    table.insert(existing_ids, chapter_id)
  end
  local new_id = id_util.generate(existing_ids)

  -- Create chapter directory on disk
  local chapter_dir = Path:new(state.manuscript.root, "chapters", new_id)
  chapter_dir:mkdir({ parents = true })

  -- Create empty text.md
  local text_file = Path:new(chapter_dir:absolute(), "text.md")
  text_file:write("", "w")

  -- Find insert position (after last chapter of this section)
  local insert_pos = #state.manuscript.chapters + 1
  for i, ch in ipairs(state.manuscript.chapters) do
    if ch.section == section_id then
      insert_pos = i + 1
    end
  end

  -- Add to manuscript.chapters at the right position
  local chapter_data = { id = new_id, title = title, section = section_id }
  table.insert(state.manuscript.chapters, insert_pos, chapter_data)

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.chapters[new_id]
end

function Chapter:text_path()
  return self.root .. "/chapters/" .. self.id .. "/text.md"
end

function Chapter:notes_path()
  return self.root .. "/chapters/" .. self.id .. "/notes.md"
end

function Chapter:display_number()
  if self.section_index then
    return self.section_index .. "." .. self.chapter_index
  end
  return tostring(self.chapter_index)
end

function Chapter:update(state, attrs)
  -- Update local fields
  for k, v in pairs(attrs) do
    self[k] = v
  end

  -- Update in manuscript.chapters
  for _, ch_data in ipairs(state.manuscript.chapters) do
    if ch_data.id == self.id then
      for k, v in pairs(attrs) do
        ch_data[k] = v
      end
      break
    end
  end

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.chapters[self.id]
end

function Chapter:destroy(state)
  -- Remove chapter directory from disk
  local chapter_dir = Path:new(self.root, "chapters", self.id)
  if chapter_dir:exists() then
    vim.fn.delete(chapter_dir:absolute(), "rf")
  end

  -- Remove from manuscript.chapters
  for i, ch_data in ipairs(state.manuscript.chapters) do
    if ch_data.id == self.id then
      table.remove(state.manuscript.chapters, i)
      break
    end
  end

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return true
end

function Chapter:move(state, target_section_id, position)
  local target_section = state.sections[target_section_id]
  if not target_section then
    return nil, "Section not found: " .. target_section_id
  end

  -- Remove from current position
  local chapter_data
  for i, ch_data in ipairs(state.manuscript.chapters) do
    if ch_data.id == self.id then
      chapter_data = table.remove(state.manuscript.chapters, i)
      break
    end
  end

  -- Update section reference
  chapter_data.section = target_section_id

  -- Find insert position: position N within target section
  local section_count = 0
  local insert_pos = #state.manuscript.chapters + 1

  for i, ch in ipairs(state.manuscript.chapters) do
    if ch.section == target_section_id then
      section_count = section_count + 1
      if section_count == position then
        insert_pos = i
        break
      end
      insert_pos = i + 1
    end
  end

  -- Insert at calculated position
  table.insert(state.manuscript.chapters, insert_pos, chapter_data)

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.chapters[self.id]
end

return Chapter
