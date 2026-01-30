local Pdf = {}
Pdf.__index = Pdf

-- PDF engines in order of preference
local PDF_ENGINES = { "xelatex", "lualatex", "pdflatex" }

function Pdf.new(opts)
  return setmetatable({
    format = "pdf",
    output = opts.output,
    entries = opts.entries or {},
  }, Pdf)
end

--- Check if a PDF engine is available
---@return string|nil engine name if found, nil otherwise
function Pdf.find_engine()
  for _, engine in ipairs(PDF_ENGINES) do
    if vim.fn.executable(engine) == 1 then
      return engine
    end
  end
  return nil
end

--- Check if PDF export is available
---@return boolean
function Pdf.available()
  return Pdf.find_engine() ~= nil
end

function Pdf:assemble(files)
  -- Same as DOCX: add page breaks between entries
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
  local dir = source:match("(.*/)")
  return dir .. "../../../../templates/export/pagebreak.lua"
end

function Pdf:pandoc_args(_opts)
  local engine = Pdf.find_engine()
  local args = {
    "--pdf-engine=" .. engine,
    "--lua-filter=" .. get_filter_path(),
  }
  return args
end

return Pdf
