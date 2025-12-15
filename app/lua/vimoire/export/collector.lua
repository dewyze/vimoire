local M = {}

function M.collect_entries(state)
  local entries = {}

  local function walk(list)
    for _, item_data in ipairs(list) do
      if item_data.items then
        walk(item_data.items)
      else
        local entry = state.items[item_data.id]
        local context = entry:export_context()

        table.insert(entries, {
          id = entry.id,
          path = entry:text_path(),
          context = context,
        })
      end
    end
  end

  walk(state.manuscript.items)
  return entries
end

return M
