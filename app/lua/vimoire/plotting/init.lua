local M = {}

M.Board = require("vimoire.plotting.board")
M.buffer = require("vimoire.plotting.buffer")
M.navigation = require("vimoire.plotting.navigation")
M.editor = require("vimoire.plotting.editor")
M.renderer = require("vimoire.plotting.renderer")

function M.setup()
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "vimoire://plotting/*",
    callback = function(args)
      local id = args.file:match("vimoire://plotting/(.+)$")
      if not id then
        return
      end

      local state = require("vimoire.state")
      local board = state.items[id]
      if not board then
        vim.notify("Board not found: " .. id, vim.log.levels.ERROR)
        return
      end

      M.buffer.setup_buffer(args.buf, board)
    end,
  })
end

return M
