local Section = {}
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
  local section_data = { id = new_id, title = title }
  table.insert(state.manuscript.sections, section_data)

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.sections[new_id]
end

function Section:update(state, attrs)
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

  -- Persist and rebuild
  state.manuscript:save()
  state:rebuild()

  return state.sections[self.id]
end

function Section:destroy(state)
  -- Ungroup all entries in this section (don't delete them)
  for _, entry_data in ipairs(state.manuscript.entries) do
    if entry_data.section == self.id then
      entry_data.section = nil
    end
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

return Section
