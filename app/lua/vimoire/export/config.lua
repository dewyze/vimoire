local collector = require("vimoire.export.collector")
local tinyyaml = require("vendor.tinyyaml")

local M = {}

local formats = {
  epub = require("vimoire.export.format.epub"),
  docx = require("vimoire.export.format.docx"),
}

function M.for_format(format_name)
  local Format = formats[format_name] or formats.epub
  return Format.new({ entries = {} })
end

function M.generate(state)
  local entries = collector.collect_entries(state)
  local lines = {
    "# Supported formats: epub, docx",
    "format: epub",
    "",
    "# output: " .. M._sanitize_filename(state.book.title) .. ".epub",
    "",
    "entries:",
  }

  for _, entry in ipairs(entries) do
    local comment = M._entry_comment(entry)
    table.insert(lines, "  - " .. entry.id .. "  " .. comment)
  end

  return table.concat(lines, "\n") .. "\n"
end

function M._entry_comment(entry)
  local context = entry.context
  if context.num then
    return "# " .. context.title .. " (chapter " .. context.num .. ")"
  else
    return "# " .. context.title .. " (page)"
  end
end

function M._sanitize_filename(title)
  return title:gsub("[^%w%s%-_]", ""):gsub("%s+", "_")
end

function M.parse(yaml_string)
  local parsed = tinyyaml.parse(yaml_string) or {}
  local format_name = parsed.format or "epub"
  local Format = formats[format_name] or formats.epub

  local entries = {}
  if parsed.entries then
    for _, entry_id in ipairs(parsed.entries) do
      table.insert(entries, entry_id)
    end
  end

  return Format.new({
    output = parsed.output,
    entries = entries,
  })
end

function M.load(config_path)
  local file = io.open(config_path, "r")
  if not file then
    return nil, "Could not open config file: " .. config_path
  end

  local content = file:read("*a")
  file:close()

  return M.parse(content)
end

function M.update(state, existing_yaml)
  local parsed = M.parse(existing_yaml)
  local excluded = M._find_commented_entries(existing_yaml)
  local entries = collector.collect_entries(state)

  local lines = {
    "format: " .. parsed.format,
  }

  if parsed.output then
    table.insert(lines, "output: " .. parsed.output)
  end

  table.insert(lines, "")
  table.insert(lines, "entries:")

  for _, entry in ipairs(entries) do
    local comment = M._entry_comment(entry)
    local prefix = excluded[entry.id] and "  # - " or "  - "
    table.insert(lines, prefix .. entry.id .. "  " .. comment)
  end

  return table.concat(lines, "\n") .. "\n"
end

function M._find_commented_entries(yaml_string)
  local excluded = {}
  for line in yaml_string:gmatch("[^\n]+") do
    local id = line:match("^%s*#%s*-%s*(%w+)")
    if id then
      excluded[id] = true
    end
  end
  return excluded
end

return M
