local Entry = {}

local id_util = require("vimoire.util.id")

-- Factory: returns the appropriate class instance
function Entry.build(data, root, opts)
  local kind = data.kind
  if kind == "section" then
    return require("vimoire.core.section").new(data, root, opts)
  elseif kind == "page" then
    return require("vimoire.core.page").new(data, root, opts)
  else
    return require("vimoire.core.chapter").new(data, root, opts)
  end
end

-- Shared: generate unique ID not in use
function Entry.generate_id(existing_ids)
  return id_util.generate(existing_ids)
end

-- Shared: collect all IDs from nested items tree
function Entry.collect_ids(items, ids)
  ids = ids or {}
  for _, item in ipairs(items) do
    if item.id then
      table.insert(ids, item.id)
    end
    if item.items then
      Entry.collect_ids(item.items, ids)
    end
  end
  return ids
end

-- Shared: find index of item in array by ID
function Entry.find_index(items, id)
  for i, item in ipairs(items) do
    if item.id == id then return i end
  end
end

return Entry
