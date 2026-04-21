local M = {}

local function shorten_home(path)
  return path:gsub("^" .. vim.pesc(vim.fn.expand("~")), "~")
end

-- Open a recursive picker.
-- opts.start: initial path
-- opts.entries(path) -> list of items, each: { type, path, display, ... }
--   type "nav" → recurse into item.path
--   anything else → invoke opts.on_select(item) and stop
-- opts.on_select(item): called with the chosen item
function M.open(opts)
  local function show(path)
    path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
    vim.ui.select(opts.entries(path), {
      prompt = shorten_home(path),
      format_item = function(item) return item.display end,
    }, function(choice)
      if not choice then return end
      if choice.type == "nav" then
        show(choice.path)
      else
        opts.on_select(choice)
      end
    end)
  end
  show(opts.start)
end

return M
