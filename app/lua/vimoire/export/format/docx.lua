local Docx = {}
Docx.__index = Docx

function Docx.new(opts)
  return setmetatable({
    format = "docx",
    output = opts.output,
    entries = opts.entries or {},
  }, Docx)
end

function Docx:assemble(files)
  local result = {}
  for i, file in ipairs(files) do
    local content = file.content
    if i < #files then
      content = content .. "\n\n\\newpage\n"
    end
    table.insert(result, { id = file.id, content = content })
  end
  return result
end

local function get_filter_path()
  local source = debug.getinfo(1, "S").source:sub(2)
  -- Go up from app/lua/vimoire/export/format/ to app/
  local dir = source:match("(.*/)")
  return dir .. "../../../../templates/export/pagebreak.lua"
end

function Docx:pandoc_args(opts)
  local args = { "--lua-filter=" .. get_filter_path() }
  if opts.reference_doc then
    table.insert(args, "--reference-doc=" .. opts.reference_doc)
  end
  return args
end

return Docx
