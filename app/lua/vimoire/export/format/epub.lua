local Epub = {}
Epub.__index = Epub

function Epub.new(opts)
  return setmetatable({
    format = "epub",
    output = opts.output,
    entries = opts.entries or {},
  }, Epub)
end

function Epub:assemble(files)
  return files
end

function Epub:pandoc_args(opts)
  local args = { "--split-level=1" }
  if opts.css_path then
    table.insert(args, "--css=" .. opts.css_path)
  end
  if opts.cover_path then
    table.insert(args, "--epub-cover-image=" .. opts.cover_path)
  end
  return args
end

return Epub
