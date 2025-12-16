local collector = require("vimoire.export.collector")
local config = require("vimoire.export.config")
local pipeline = require("vimoire.export.pipeline")
local frontmatter = require("vimoire.export.frontmatter")
local template = require("vimoire.export.template")
local Path = require("plenary.path")

local M = {}

local function get_app_template_root()
  local app_root = debug.getinfo(1, "S").source:sub(2):match("(.*/app/)")
  return app_root and (app_root .. "templates/export/") or nil
end

-- Find a template file, checking project first then app defaults
local function find_template(root, filename)
  local project_path = root .. "/exports/templates/" .. filename
  if Path:new(project_path):exists() then
    return project_path
  end

  local app_root = get_app_template_root()
  if app_root then
    local app_path = app_root .. filename
    if Path:new(app_path):exists() then
      return app_path
    end
  end

  return nil
end

-- Load chapter template from project or fall back to default
local function load_chapter_template(root)
  local project_template = root .. "/exports/templates/chapter.md"
  local loaded = template.load(project_template)
  if loaded then
    return loaded
  end

  -- Fall back to app default
  local app_root = get_app_template_root()
  if app_root then
    local default_template = app_root .. "chapter.md"
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

local function write_log(output_dir, content)
  if not content or content == "" then return end
  local log_path = output_dir .. "/export.log"
  Path:new(log_path):write(content, "w")
end

function M.run(state, opts)
  opts = opts or {}
  local format = opts.format or "epub"
  local cfg = config.for_format(format)

  -- Check pandoc
  if vim.fn.executable("pandoc") ~= 1 then
    return {
      success = false,
      error = "pandoc not found. Install it with: brew install pandoc (macOS) or apt install pandoc (Linux)",
    }
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
  local root = state.manuscript.root
  local args = M.build_pandoc_args({
    input_files = input_files,
    output_path = output_path,
    title = state.book.title,
    author = state.book.author,
    language = state.book.language,
    css_path = find_template(root, "epub.css"),
    reference_doc = find_template(root, "reference.docx"),
  }, cfg)

  local cmd = { "pandoc" }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local result = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  -- Cleanup temp files
  vim.fn.delete(temp_dir, "rf")

  -- Write log on failure
  if not success then
    write_log(output_dir, result)
  end

  if success then
    return { success = true, output_path = output_path }
  else
    return { success = false, error = result, log_path = output_dir .. "/export.log" }
  end
end

function M.run_with_config(state, config_path)
  local cfg, err = config.load(config_path)
  if not cfg then
    return { success = false, error = "Invalid config: " .. (err or "unknown error") }
  end

  if not cfg.entries or #cfg.entries == 0 then
    return { success = false, error = "No entries in config. Add entries or run :VimoireExportConfig to regenerate." }
  end

  -- Check pandoc
  if vim.fn.executable("pandoc") ~= 1 then
    return {
      success = false,
      error = "pandoc not found. Install it with: brew install pandoc (macOS) or apt install pandoc (Linux)",
    }
  end

  -- Collect only the entries specified in config
  local entries = collector.collect_by_ids(state, cfg.entries)

  if #entries == 0 then
    return { success = false, error = "No valid entries found. Check that entry IDs in config match your manuscript." }
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
  local root = state.manuscript.root
  local args = M.build_pandoc_args({
    input_files = input_files,
    output_path = output_path,
    title = state.book.title,
    author = state.book.author,
    language = state.book.language,
    css_path = find_template(root, "epub.css"),
    reference_doc = find_template(root, "reference.docx"),
  }, cfg)

  local cmd = { "pandoc" }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local result = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  -- Cleanup temp files
  vim.fn.delete(temp_dir, "rf")

  -- Write log on failure
  if not success then
    write_log(output_dir, result)
  end

  if success then
    return { success = true, output_path = output_path }
  else
    return { success = false, error = result, log_path = output_dir .. "/export.log" }
  end
end

return M
