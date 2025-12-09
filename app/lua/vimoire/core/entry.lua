local Entry = {}

local Section = require("vimoire.core.section")
local Document = require("vimoire.core.document")

function Entry.build(data, root, opts)
  if data.kind == "section" then
    return Section.new(data, root, opts)
  else
    opts = opts or {}
    opts.base = "entries"
    opts.extras = true
    return Document.new(data, root, opts)
  end
end

return Entry
