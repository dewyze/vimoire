local M = {}

local Entry = require("vimoire.core.entry")

local function get_context(state, id)
  local item = state.items[id]
  if not item then return nil end
  local index = Entry.find_index(item.parent_items, id)
  return item, item.parent_items, index
end

local function has_sibling(items, index, direction)
  local target = index + direction
  return target >= 1 and target <= #items
end

local function move(state, id, direction)
  local item, items, index = get_context(state, id)
  if not item then return false end

  if has_sibling(items, index, direction) then
    local adjacent = items[index + direction]
    if adjacent.items then
      local insert_pos = direction == -1 and #adjacent.items + 1 or 1
      table.insert(adjacent.items, insert_pos, table.remove(items, index))
    else
      items[index], items[index + direction] = items[index + direction], items[index]
    end
  elseif item.parent_section then
    local section = item.parent_section
    local section_index = Entry.find_index(section.parent_items, section.id)
    local insert_pos = direction == -1 and section_index or section_index + 1
    table.insert(section.parent_items, insert_pos, table.remove(items, index))
  else
    return false
  end

  state:save()
  return true
end

function M.move_up(state, id)
  return move(state, id, -1)
end

function M.move_down(state, id)
  return move(state, id, 1)
end

return M
