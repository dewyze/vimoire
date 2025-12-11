local DocumentBase = require("vimoire.core.document_base")

local Page = {}
Page.__index = Page
setmetatable(Page, { __index = DocumentBase })

Page.KIND = "page"
Page.BASE = "entries"

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

return Page
