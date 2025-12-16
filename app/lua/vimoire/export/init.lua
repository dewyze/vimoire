local collector = require("vimoire.export.collector")
local config = require("vimoire.export.config")
local pipeline = require("vimoire.export.pipeline")
local frontmatter = require("vimoire.export.frontmatter")
local template = require("vimoire.export.template")
local Path = require("plenary.path")

local M = {}

-- Load chapter template from project or fall back to default
local function load_chapter_template(root)
  local project_template = root .. "/exports/templates/chapter.md"
  local loaded = template.load(project_template)
  if loaded then
    return loaded
  end

  -- Fall back to app default
  local app_root = debug.getinfo(1, "S").source:sub(2):match("(.*/app/)")
  if app_root then
    local default_template = app_root .. "templates/export/chapter.md"
    loaded = template.load(default_template)
    if loaded then
      return loaded
    end
  end

  return template.DEFAULT_CHAPTER
end

function M.prepare_files(state, entries)
  entries = entries or collector.collect_entries(state)
  local chapter_template = load_chapter_template(state.manuscript.root)
  local files = {}

  for _, entry in ipairs(entries) do
    local prose_path = Path:new(entry.path)
    local content = ""

    if prose_path:exists() then
      content = prose_path:read() or ""
    end

    -- Parse frontmatter from content
    local fm, body = frontmatter.parse(content)

    local processed = pipeline.process_entry(body, entry.context, {
      frontmatter = fm,
      chapter_template = chapter_template,
    })

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

function M.build_pandoc_args(opts, cfg)
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
  local format_args = cfg:pandoc_args(opts)
  for _, arg in ipairs(format_args) do
    table.insert(args, arg)
  end

  return args
end

local function sanitize_filename(name)
  return name:gsub("[^%w%s%-_]", ""):gsub("%s+", "_")
end

function M.run(state, opts)
  opts = opts or {}
  local format = opts.format or "epub"
  local cfg = config.for_format(format)

  -- Check pandoc
  if vim.fn.executable("pandoc") ~= 1 then
    return { success = false, error = "pandoc not found" }
  end

  -- Prepare and assemble files
  local files = M.prepare_files(state)
  files = cfg:assemble(files)
  local temp_dir, input_files = M.write_temp_files(files)

  -- Output path
  local output_dir = state.manuscript.root .. "/exports/output"
  vim.fn.mkdir(output_dir, "p")

  local filename = sanitize_filename(state.book.title) .. "." .. format
  local output_path = output_dir .. "/" .. filename

  -- Build and run pandoc
  local args = M.build_pandoc_args({
    input_files = input_files,
    output_path = output_path,
    title = state.book.title,
    author = state.book.author,
    language = state.book.language,
  }, cfg)

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

function M.run_with_config(state, config_path)
  local cfg, err = config.load(config_path)
  if not cfg then
    return { success = false, error = err }
  end

  if not cfg.entries or #cfg.entries == 0 then
    return { success = false, error = "Nothing to export" }
  end

  -- Check pandoc
  if vim.fn.executable("pandoc") ~= 1 then
    return { success = false, error = "pandoc not found" }
  end

  -- Collect only the entries specified in config
  local entries = collector.collect_by_ids(state, cfg.entries)

  if #entries == 0 then
    return { success = false, error = "Nothing to export" }
  end

  -- Prepare and assemble files
  local files = M.prepare_files(state, entries)
  files = cfg:assemble(files)
  local temp_dir, input_files = M.write_temp_files(files)

  -- Output path
  local output_dir = state.manuscript.root .. "/exports/output"
  vim.fn.mkdir(output_dir, "p")

  local filename = cfg.output or (sanitize_filename(state.book.title) .. "." .. cfg.format)
  local output_path = output_dir .. "/" .. filename

  -- Build and run pandoc
  local args = M.build_pandoc_args({
    input_files = input_files,
    output_path = output_path,
    title = state.book.title,
    author = state.book.author,
    language = state.book.language,
  }, cfg)

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
