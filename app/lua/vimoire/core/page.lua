local DocumentBase = require("vimoire.core.document_base")
local add_options = require("vimoire.core.add_options")

local Page = {}
Page.__index = Page
setmetatable(Page, { __index = DocumentBase })

Page.KIND = "page"
Page.BASE = "entries"
Page.TEXT_FILENAME = "prose.md"
Page.ADD_OPTIONS = { add_options.CHAPTER, add_options.PAGE, add_options.SECTION }

function Page.new(data, root)
  local self = DocumentBase.new(data, root)
  setmetatable(self, Page)
  self.kind = Page.KIND
  return self
end

function Page.create(state, name, parent_items, at_index)
  return DocumentBase.create_document(Page, state, name, parent_items, at_index)
end

function Page:base()
  return Page.BASE
end

function Page:extras()
  return true
end

function Page:text_path()
  return self:dir_path() .. "/" .. Page.TEXT_FILENAME
end

function Page:export_context()
  return {
    title = self.name,
    actions = {},
  }
end

function Page:toggle(state)
  self:update(state, { kind = "chapter" })
  state:load(state.manuscript.root)
  return true
end

function Page:add_options()
  return Page.ADD_OPTIONS
end

return Page
