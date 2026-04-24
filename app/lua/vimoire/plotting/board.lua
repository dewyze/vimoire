local persistence = require("vimoire.plotting.persistence")
local id_util = require("vimoire.util.id")
local scandir = require("plenary.scandir")

local Board = {}
Board.__index = Board

function Board.new(id, name, path)
  local self = setmetatable({}, Board)
  self.id = id
  self.name = name
  self.kind = "plotting_board"
  self.path = path
  self.columns = {}
  self.rows = {}
  return self
end

function Board.load(path)
  local data = persistence.read(path)
  if not data then
    return nil
  end

  local self = setmetatable({}, Board)
  self.id = data.id
  self.name = data.name
  self.kind = "plotting_board"
  self.path = path
  self.columns = data.columns or {}
  self.rows = data.rows or {}
  return self
end

function Board.create(state, name, parent_items, at_index)
  local root = state.manuscript.root
  local plotting_dir = root .. "/plotting"

  -- Ensure directory exists
  vim.fn.mkdir(plotting_dir, "p")

  local id = id_util.generate(state.items)
  local path = plotting_dir .. "/" .. id .. ".json"

  local board = Board.new(id, name, path)

  -- Create default structure: one column, one row
  local col_id = id_util.generate({ [id] = true })
  local row_id = id_util.generate({ [id] = true, [col_id] = true })

  board.columns = { { id = col_id, header = "" } }
  board.rows = { { id = row_id, cells = { [col_id] = "" } } }

  board:save()

  -- Register in state
  board.parent_items = parent_items
  state.items[id] = board
  table.insert(parent_items, at_index, { id = id })

  return board
end

function Board:save()
  persistence.write(self.path, {
    id = self.id,
    name = self.name,
    columns = self.columns,
    rows = self.rows,
  })
end

function Board:display_name()
  return self.name
end

function Board:text_path()
  return "vimoire://plotting/" .. self.id
end

function Board:render_extras()   return {} end

function Board:add_options()
  return nil
end

function Board:add_parent_items()
  return self.parent_items
end

function Board:add_index()
  if not self.parent_items then
    return 1
  end
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      return i + 1
    end
  end
  return #self.parent_items + 1
end

function Board:destroy(state)
  -- Remove from parent folder's items
  if self.parent_items then
    for i, item in ipairs(self.parent_items) do
      if item.id == self.id then
        table.remove(self.parent_items, i)
        break
      end
    end
  end

  -- Delete file
  vim.fn.delete(self.path)

  -- Remove from state
  state.items[self.id] = nil

  return true
end

function Board:category()
  return "plotting"
end

-- Cell operations

function Board:get_cell(row_id, col_id)
  for _, row in ipairs(self.rows) do
    if row.id == row_id then
      return row.cells[col_id] or ""
    end
  end
  return ""
end

function Board:set_cell(row_id, col_id, value)
  for _, row in ipairs(self.rows) do
    if row.id == row_id then
      row.cells[col_id] = value
      self:save()
      return true
    end
  end
  return false
end

-- Row/column operations

function Board:add_row(after_index)
  local row_id = id_util.generate(self:_all_ids())
  local cells = {}
  for _, col in ipairs(self.columns) do
    cells[col.id] = ""
  end

  local row = { id = row_id, cells = cells }
  local index = after_index and (after_index + 1) or (#self.rows + 1)
  table.insert(self.rows, index, row)
  self:save()
  return row_id, index
end

function Board:add_column(after_index)
  local col_id = id_util.generate(self:_all_ids())
  local col = { id = col_id, header = "" }
  local index = after_index and (after_index + 1) or (#self.columns + 1)
  table.insert(self.columns, index, col)

  -- Add empty cell to each row
  for _, row in ipairs(self.rows) do
    row.cells[col_id] = ""
  end

  self:save()
  return col_id, index
end

function Board:delete_row(index)
  if #self.rows <= 1 then
    return false, "Cannot delete last row"
  end
  table.remove(self.rows, index)
  self:save()
  return true
end

function Board:delete_column(index)
  if #self.columns <= 1 then
    return false, "Cannot delete last column"
  end
  local col = self.columns[index]
  table.remove(self.columns, index)

  -- Remove cells from all rows
  for _, row in ipairs(self.rows) do
    row.cells[col.id] = nil
  end

  self:save()
  return true
end

function Board:set_column_header(col_index, header)
  if self.columns[col_index] then
    self.columns[col_index].header = header
    self:save()
    return true
  end
  return false
end

-- Internal helpers

function Board:_all_ids()
  local ids = { [self.id] = true }
  for _, col in ipairs(self.columns) do
    ids[col.id] = true
  end
  for _, row in ipairs(self.rows) do
    ids[row.id] = true
  end
  return ids
end

function Board.scan_folder(state, dir_path)
  local items = {}
  local paths = scandir.scan_dir(dir_path, {
    depth = 1,
    add_dirs = false,
    hidden = true,
    search_pattern = "%.json$",
    silent = true,
  })
  for _, file_path in ipairs(paths) do
    local board = Board.load(file_path)
    if board then
      board.parent_items = items
      state.items[board.id] = board
      table.insert(items, { id = board.id })
    end
  end
  table.sort(items, function(a, b)
    return a.id < b.id
  end)
  return items
end

return Board
