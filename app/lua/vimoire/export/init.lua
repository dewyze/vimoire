local collector = require("vimoire.export.collector")
local pipeline = require("vimoire.export.pipeline")
local Path = require("plenary.path")

local M = {}

function M.prepare_files(state)
  local entries = collector.collect_entries(state)
  local files = {}

  for _, entry in ipairs(entries) do
    local prose_path = Path:new(entry.path)
    local content = ""

    if prose_path:exists() then
      content = prose_path:read() or ""
    end

    local processed = pipeline.process_entry(content, entry.context)

    table.insert(files, {
      id = entry.id,
      content = processed,
    })
  end

  return files
end

function M.write_temp_files(files)
  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")

  local file_list = {}

  for i, file in ipairs(files) do
    local file_path = temp_dir .. "/" .. string.format("%03d", i) .. "_" .. file.id .. ".md"
    Path:new(file_path):write(file.content, "w")
    table.insert(file_list, file_path)
  end

  return temp_dir, file_list
end

function M.build_pandoc_args(opts)
  local args = {}

  -- Input files
  for _, file in ipairs(opts.input_files) do
    table.insert(args, file)
  end

  -- Output
  table.insert(args, "-o")
  table.insert(args, opts.output_path)

  -- Metadata
  table.insert(args, "--metadata")
  table.insert(args, "title=" .. opts.title)
  table.insert(args, "--metadata")
  table.insert(args, "author=" .. opts.author)
  table.insert(args, "--metadata")
  table.insert(args, "lang=" .. opts.language)

  -- Format-specific options
  if opts.format == "epub" then
    -- Split on H1 so each chapter becomes a separate XHTML file
    table.insert(args, "--split-level=1")
    if opts.css_path then
      table.insert(args, "--css=" .. opts.css_path)
    end
  elseif opts.format == "docx" then
    if opts.reference_doc then
      table.insert(args, "--reference-doc=" .. opts.reference_doc)
    end
  end

  return args
end

local function sanitize_filename(name)
  return name:gsub("[^%w%s%-_]", ""):gsub("%s+", "_")
end

function M.run(state, opts)
  opts = opts or {}
  local format = opts.format or "epub"

  -- Check pandoc
  if vim.fn.executable("pandoc") ~= 1 then
    return { success = false, error = "pandoc not found" }
  end

  -- Prepare files
  local files = M.prepare_files(state)
  local temp_dir, input_files = M.write_temp_files(files)

  -- Output path
  local output_dir = state.manuscript.root .. "/exports/builds"
  vim.fn.mkdir(output_dir, "p")

  local filename = sanitize_filename(state.book.title) .. "." .. format
  local output_path = output_dir .. "/" .. filename

  -- Build and run pandoc
  local args = M.build_pandoc_args({
    format = format,
    input_files = input_files,
    output_path = output_path,
    title = state.book.title,
    author = state.book.author,
    language = state.book.language,
  })

  local cmd = { "pandoc" }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local result = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  -- Cleanup temp files
  vim.fn.delete(temp_dir, "rf")

  if success then
    return { success = true, output_path = output_path }
  else
    return { success = false, error = result }
  end
end

return M
