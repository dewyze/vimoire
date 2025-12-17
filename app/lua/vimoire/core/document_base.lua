local DocumentBase = {}
DocumentBase.__index = DocumentBase

local Path = require("plenary.path")

local FILE_DISPLAY_SUFFIXES = {
  ["notes.md"] = " - Notes",
}
local id_util = require("vimoire.util.id")
local items_util = require("vimoire.util.items")

function DocumentBase.new(data, root)
  local self = setmetatable({}, DocumentBase)
  self.id = data.id
  self.name = data.name
  self.kind = data.kind
  self.root = root
  return self
end

function DocumentBase:dir_path()
  return self.root .. "/" .. self:base() .. "/" .. self.id
end

function DocumentBase:text_path()
  error("Subclass must implement text_path()")
end

function DocumentBase:notes_path()
  if not self:extras() then return nil end
  return self:dir_path() .. "/notes.md"
end

function DocumentBase:display_number()
  return self.chapter_index and tostring(self.chapter_index) or nil
end

function DocumentBase:display_name()
  local num = self:display_number()
  if num then
    return num .. ": " .. self.name
  end
  return self.name
end

function DocumentBase:action()
  vim.cmd.edit(self:text_path())
  return true
end

function DocumentBase:display_name_for_path(filepath)
  local filename = filepath:match("([^/]+)$")
  local suffix = FILE_DISPLAY_SUFFIXES[filename] or ""
  return self:display_name() .. suffix
end

function DocumentBase:add_parent_items()
  return self.parent_items
end

function DocumentBase:add_index()
  local index = items_util.find_index(self.parent_items, self.id)
  return index and (index + 1) or 1
end

function DocumentBase.create_document(class, state, name, parent_items, at_index)
  local new_id = id_util.generate(state.items)

  local data = {
    id = new_id,
    name = name,
    kind = class.KIND,
  }

  -- Create directory and text file with frontmatter
  local doc_dir = Path:new(state.manuscript.root, class.BASE, new_id)
  doc_dir:mkdir({ parents = true })
  local text_file = Path:new(doc_dir:absolute(), class.TEXT_FILENAME)
  local frontmatter = string.format("---\ntitle: %s\n# subtitle: \n# epigraph: \n---\n\n", name)
  text_file:write(frontmatter, "w")

  table.insert(parent_items, at_index, data)
  state:save()

  return state.items[new_id]
end

function DocumentBase:update(state, attrs)
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      for k, v in pairs(attrs) do
        self[k] = v
        self.parent_items[i][k] = v
      end
      break
    end
  end

  state:save()
  return state.items[self.id]
end

function DocumentBase:destroy_children(_state)
  -- Documents have no children
end

function DocumentBase:preserve_notes(state)
  if not self:extras() then return end

  local notes = Path:new(self:notes_path())
  if not notes:exists() then return end

  local content = notes:read()

  -- Ensure orphaned_notes array exists
  if not state.manuscript.orphaned_notes then
    state.manuscript.orphaned_notes = {}
  end

  -- Create planning item for the orphaned note
  local PlanningItem = require("vimoire.core.planning_item")
  local item = PlanningItem.create(state, self:display_name(), state.manuscript.orphaned_notes, 1)

  -- Write notes content to the new item
  Path:new(item:text_path()):write(content, "w")
end

function DocumentBase:destroy(state)
  self:preserve_notes(state)

  -- Find and remove from parent_items
  for i, item in ipairs(self.parent_items) do
    if item.id == self.id then
      table.remove(self.parent_items, i)
      break
    end
  end

  -- Delete directory
  local doc_dir = Path:new(self:dir_path())
  if doc_dir:exists() then
    vim.fn.delete(doc_dir:absolute(), "rf")
  end

  state:save()
  return true
end

-- Abstract methods - subclasses must implement
function DocumentBase:base()
  error("Subclass must implement base()")
end

function DocumentBase:extras()
  error("Subclass must implement extras()")
end

return DocumentBase
