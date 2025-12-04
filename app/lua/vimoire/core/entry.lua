local Entry = {}
local Path = require("plenary.path")
local id_util = require("vimoire.util.id")

function Entry.new(data, root)
  local self = setmetatable(data, { __index = Entry })
  self.root = root
  return self
end

function Entry.create(state, kind, title, section_id)
  if section_id then
    local section = state.sections[section_id]
    if not section then
      return nil, "Section not found: " .. section_id
    end
  end

  -- Generate unique ID
  local existing_ids = {}
  for entry_id, _ in pairs(state.entries) do
    table.insert(existing_ids, entry_id)
  end
  local new_id = id_util.generate(existing_ids)

  -- Create entry directory on disk
  local entry_dir = Path:new(state.manuscript.root, "entries", new_id)
  entry_dir:mkdir({ parents = true })

  -- Create empty text.md
  local text_file = Path:new(entry_dir:absolute(), "text.md")
  text_file:write("", "w")

  -- Find insert position (after last entry of this section, or at end)
  local insert_pos = #state.manuscript.entries + 1
  if section_id then
    for i, entry in ipairs(state.manuscript.entries) do
      if entry.section == section_id then
        insert_pos = i + 1
      end
    end
  end

  -- Add to manuscript.entries at the right position
  local entry_data = { id = new_id, kind = kind, title = title, section = section_id }
  table.insert(state.manuscript.entries, insert_pos, entry_data)

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.entries[new_id]
end

function Entry:text_path()
  return self.root .. "/entries/" .. self.id .. "/text.md"
end

function Entry:notes_path()
  return self.root .. "/entries/" .. self.id .. "/notes.md"
end

function Entry:display_number()
  if self.kind ~= "chapter" then
    return nil
  end
  if self.section_index then
    return self.section_index .. "." .. self.chapter_index
  end
  return tostring(self.chapter_index)
end

function Entry:update(state, attrs)
  -- Update local fields
  for k, v in pairs(attrs) do
    self[k] = v
  end

  -- Update in manuscript.entries
  for _, entry_data in ipairs(state.manuscript.entries) do
    if entry_data.id == self.id then
      for k, v in pairs(attrs) do
        entry_data[k] = v
      end
      break
    end
  end

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.entries[self.id]
end

function Entry:destroy(state)
  -- Remove entry directory from disk
  local entry_dir = Path:new(self.root, "entries", self.id)
  if entry_dir:exists() then
    vim.fn.delete(entry_dir:absolute(), "rf")
  end

  -- Remove from manuscript.entries
  for i, entry_data in ipairs(state.manuscript.entries) do
    if entry_data.id == self.id then
      table.remove(state.manuscript.entries, i)
      break
    end
  end

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return true
end

function Entry:move(state, target_section_id, position)
  if target_section_id then
    local target_section = state.sections[target_section_id]
    if not target_section then
      return nil, "Section not found: " .. target_section_id
    end
  end

  -- Remove from current position
  local entry_data
  for i, data in ipairs(state.manuscript.entries) do
    if data.id == self.id then
      entry_data = table.remove(state.manuscript.entries, i)
      break
    end
  end

  -- Update section reference
  entry_data.section = target_section_id

  -- Find insert position: position N within target section (or at end if no section)
  local section_count = 0
  local insert_pos = #state.manuscript.entries + 1

  if target_section_id then
    for i, entry in ipairs(state.manuscript.entries) do
      if entry.section == target_section_id then
        section_count = section_count + 1
        if section_count == position then
          insert_pos = i
          break
        end
        insert_pos = i + 1
      end
    end
  else
    -- For unsectioned entries, position from start of unsectioned
    local unsectioned_count = 0
    for i, entry in ipairs(state.manuscript.entries) do
      if not entry.section then
        unsectioned_count = unsectioned_count + 1
        if unsectioned_count == position then
          insert_pos = i
          break
        end
        insert_pos = i + 1
      end
    end
  end

  -- Insert at calculated position
  table.insert(state.manuscript.entries, insert_pos, entry_data)

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.entries[self.id]
end

return Entry
