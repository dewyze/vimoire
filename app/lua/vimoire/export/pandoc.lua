local M = {}

--- Check if pandoc is available on the system
---@return boolean
function M.available()
  return vim.fn.executable("pandoc") == 1
end

--- Build pandoc command arguments
---@param opts table { input_files, output_path, title, author, language, css_path?, reference_doc?, cover_path? }
---@param cfg table Format config with :pandoc_args(opts) method
---@return string[]
function M.build_args(opts, cfg)
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

--- Execute pandoc with the given arguments
---@param args string[] Arguments to pass to pandoc
---@return { success: boolean, output?: string, error?: string }
function M.run(args)
  local cmd = { "pandoc" }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local result = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0

  if success then
    return { success = true, output = result }
  else
    return { success = false, error = result }
  end
end

return M
