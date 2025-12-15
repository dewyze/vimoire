local DocumentBase = require("vimoire.core.document_base")
local actions = require("vimoire.export.actions")

local Chapter = {}
Chapter.__index = Chapter
setmetatable(Chapter, { __index = DocumentBase })

Chapter.KIND = "chapter"
Chapter.BASE = "entries"
Chapter.TEXT_FILENAME = "prose.md"

function Chapter.new(data, root)
  local self = DocumentBase.new(data, root)
  setmetatable(self, Chapter)
  self.kind = Chapter.KIND
  return self
end

function Chapter.create(state, name, parent_items, at_index)
  return DocumentBase.create_document(Chapter, state, name, parent_items, at_index)
end

function Chapter:base()
  return Chapter.BASE
end

function Chapter:extras()
  return true
end

function Chapter:text_path()
  return self:dir_path() .. "/" .. Chapter.TEXT_FILENAME
end

function Chapter:export_context()
  return {
    title = self.name,
    num = self.chapter_index,
    actions = { actions.inject_title },
  }
end

return Chapter
