local collector = require("vimoire.export.collector")
local config = require("vimoire.export.config")
local pipeline = require("vimoire.export.pipeline")
local frontmatter = require("vimoire.export.frontmatter")
local template = require("vimoire.export.template")
local pandoc = require("vimoire.export.pandoc")
local Path = require("plenary.path")

local M = {}

local function resolve_cover_path(state)
  if not state.book.cover then
    return nil
  end
  local cover_path = state.manuscript.root .. "/" .. state.book.cover
  if Path:new(cover_path):exists() then
    return cover_path
  end
  return nil
end

function M.prepare_files(state, entries)
  entries = entries or collector.collect_entries(state)
  local chapter_template = template.load_chapter(state.manuscript.root)
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

local function copy_assets_to_temp(root, temp_dir)
  local assets_src = root .. "/assets"
  if Path:new(assets_src):exists() then
    local assets_dst = temp_dir .. "/assets"
    vim.fn.system({ "cp", "-r", assets_src, assets_dst })
  end
end

function M.build_pandoc_args(opts, cfg)
  return pandoc.build_args(opts, cfg)
end

local function sanitize_filename(name)
  return name:gsub("[^%w%s%-_]", ""):gsub("%s+", "_")
end

local function write_log(output_dir, content)
  if not content or content == "" then return end
  local log_path = output_dir .. "/export.log"
  Path:new(log_path):write(content, "w")
end

local function execute(state, entries, cfg, output_filename)
  if not pandoc.available() then
    return {
      success = false,
      error = "pandoc not found. Install it with: brew install pandoc (macOS) or apt install pandoc (Linux)",
    }
  end

  local files = M.prepare_files(state, entries)
  files = cfg:assemble(files)
  local temp_dir, input_files = M.write_temp_files(files)
  copy_assets_to_temp(state.manuscript.root, temp_dir)

  local output_dir = state.manuscript.root .. "/exports/output"
  vim.fn.mkdir(output_dir, "p")
  local output_path = output_dir .. "/" .. output_filename

  local root = state.manuscript.root
  local args = M.build_pandoc_args({
    input_files = input_files,
    output_path = output_path,
    title = state.book.title,
    author = state.book.author,
    language = state.book.language,
    css_path = template.find(root, "epub.css"),
    reference_doc = template.find(root, "reference.docx"),
    cover_path = resolve_cover_path(state),
  }, cfg)

  local result = pandoc.run(args)

  vim.fn.delete(temp_dir, "rf")

  if not result.success then
    write_log(output_dir, result.error)
    return { success = false, error = result.error, log_path = output_dir .. "/export.log" }
  end

  return { success = true, output_path = output_path }
end

function M.run(state, opts)
  opts = opts or {}
  local format = opts.format or "epub"
  local cfg = config.for_format(format)
  local filename = sanitize_filename(state.book.title) .. "." .. format

  return execute(state, nil, cfg, filename)
end

function M.run_with_config(state, config_path)
  local cfg, err = config.load(config_path)
  if not cfg then
    return { success = false, error = "Invalid config: " .. (err or "unknown error") }
  end

  if not cfg.entries or #cfg.entries == 0 then
    return { success = false, error = "No entries in config. Add entries or run :VimoireExportConfig to regenerate." }
  end

  local entries = collector.collect_by_ids(state, cfg.entries)

  if #entries == 0 then
    return { success = false, error = "No valid entries found. Check that entry IDs in config match your manuscript." }
  end

  local filename = cfg.output or (sanitize_filename(state.book.title) .. "." .. cfg.format)

  return execute(state, entries, cfg, filename)
end

return M
