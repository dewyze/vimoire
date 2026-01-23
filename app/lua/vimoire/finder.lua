local M = {}

local state = require("vimoire.state")

function M.build_manuscript_entries()
  local entries = {}

  local function process_items(items)
    for _, item_data in ipairs(items) do
      if item_data.items then
        process_items(item_data.items)
      else
        local item = state.items[item_data.id]
        if item then
          table.insert(entries, {
            id = item.id,
            display_number = item:display_number() or "",
            name = item.name,
            path = item:text_path(),
          })
        end
      end
    end
  end

  process_items(state.manuscript.items or {})
  return entries
end

function M.build_planning_entries(planning_key)
  local entries = {}

  local function process_items(items, prefix)
    for _, item_data in ipairs(items or {}) do
      if item_data.items then
        local item = state.items[item_data.id]
        local new_prefix = prefix and (prefix .. " > " .. item:display_name()) or item:display_name()
        process_items(item_data.items, new_prefix)
      else
        local item = state.items[item_data.id]
        local name = prefix and (prefix .. " > " .. item:display_name()) or item:display_name()
        table.insert(entries, {
          id = item.id,
          display_number = "",
          name = name,
          path = item:text_path(),
        })
      end
    end
  end

  process_items(state.manuscript[planning_key], nil)
  return entries
end

function M.build_all_planning_entries()
  local entries = {}

  for _, entry in ipairs(M.build_planning_entries("characters")) do
    entry.name = "Characters > " .. entry.name
    table.insert(entries, entry)
  end

  for _, entry in ipairs(M.build_planning_entries("settings")) do
    entry.name = "Settings > " .. entry.name
    table.insert(entries, entry)
  end

  for _, entry in ipairs(M.build_planning_entries("reference")) do
    entry.name = "Reference > " .. entry.name
    table.insert(entries, entry)
  end

  return entries
end

function M.build_all_entries()
  local entries = {}

  for _, entry in ipairs(M.build_manuscript_entries()) do
    table.insert(entries, entry)
  end

  for _, entry in ipairs(M.build_all_planning_entries()) do
    table.insert(entries, entry)
  end

  return entries
end

function M.build_exports_entries()
  local entries = {}
  local exports_dir = state.manuscript.root .. "/exports"
  local scan = require("plenary.scandir")

  local files = scan.scan_dir(exports_dir, {
    hidden = false,
    depth = 3,
    add_dirs = false,
  })

  for _, file_path in ipairs(files) do
    local relative = file_path:sub(#exports_dir + 2)
    table.insert(entries, {
      name = relative,
      path = file_path,
    })
  end

  return entries
end

return M
