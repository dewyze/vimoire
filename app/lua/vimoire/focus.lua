-- Focus mode for Vimoire
-- Centers prose by creating empty margin windows on left and right.

local M = {}

local vimoire_config = require("vimoire.config")

local state = {
  active = false,
  content_winid = nil,
  left_winid = nil,
  right_winid = nil,
  left_bufnr = nil,
  right_bufnr = nil,
  augroup = nil,
}

local config = {
  content_width = 80,
  min_margin = 4,
  margin_hl = "Normal",
}

local function is_neotree_buffer(bufnr)
  return vim.bo[bufnr].filetype == "neo-tree"
end

local function create_margin_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  return buf
end

local function setup_margin_window(winid)
  vim.wo[winid].winhighlight = "Normal:" .. config.margin_hl
  vim.wo[winid].number = false
  vim.wo[winid].relativenumber = false
  vim.wo[winid].signcolumn = "no"
  vim.wo[winid].foldcolumn = "0"
  vim.wo[winid].statusline = " "
  vim.wo[winid].fillchars = "eob: "
end

local function create_margin_window(position, width)
  if width <= 0 then
    return nil, nil
  end

  local split_cmd = position == "left" and "aboveleft vsplit" or "belowright vsplit"
  local bufnr = create_margin_buffer()

  vim.cmd(split_cmd)
  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.api.nvim_win_set_width(winid, width)

  setup_margin_window(winid)
  vim.w[winid].margins_role = position

  return winid, bufnr
end

local function close_window(winid)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
end

local function resize_window(winid, width)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_set_width(winid, width)
  end
end

local function is_margin_window(winid)
  local ok, role = pcall(vim.api.nvim_win_get_var, winid, "margins_role")
  return ok and (role == "left" or role == "right")
end

local function get_available_width()
  local total = vim.o.columns
  local reserved = 0

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if not is_margin_window(winid) and winid ~= state.content_winid then
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if is_neotree_buffer(bufnr) then
        reserved = reserved + vim.api.nvim_win_get_width(winid)
      end
    end
  end

  return total - reserved
end

local function calculate_margins()
  local available = get_available_width()
  local total_margin = available - config.content_width

  if total_margin < config.min_margin * 2 then
    return 0, 0
  end

  local left = math.floor(total_margin / 2)
  local right = total_margin - left
  return left, right
end

local function close_other_windows()
  local current = vim.api.nvim_get_current_win()
  local windows = vim.api.nvim_list_wins()

  for _, winid in ipairs(windows) do
    if winid ~= current then
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if not is_neotree_buffer(bufnr) then
        vim.api.nvim_win_close(winid, false)
      end
    end
  end
end

local function create_margin_windows()
  local left_width, right_width = calculate_margins()

  if left_width == 0 and right_width == 0 then
    return false
  end

  state.content_winid = vim.api.nvim_get_current_win()

  state.left_winid, state.left_bufnr = create_margin_window("left", left_width)
  vim.api.nvim_set_current_win(state.content_winid)

  state.right_winid, state.right_bufnr = create_margin_window("right", right_width)
  vim.api.nvim_set_current_win(state.content_winid)

  return true
end

local function destroy_margin_windows()
  close_window(state.left_winid)
  close_window(state.right_winid)
  state.left_winid = nil
  state.right_winid = nil
  state.left_bufnr = nil
  state.right_bufnr = nil
  state.content_winid = nil
end

local function handle_win_enter()
  local current = vim.api.nvim_get_current_win()
  if not is_margin_window(current) then
    return
  end

  local role = vim.w[current].margins_role
  -- Continue in the direction user was traveling
  -- Left margin: user came from right (prose), continue left toward neotree
  -- Right margin: user came from left (prose), continue right
  local direction = role == "left" and "h" or "l"

  vim.cmd("wincmd " .. direction)

  -- If we're still in a margin (nothing in that direction), bounce back
  local new_win = vim.api.nvim_get_current_win()
  if is_margin_window(new_win) then
    local bounce = direction == "h" and "l" or "h"
    vim.cmd("wincmd " .. bounce)
  end
end

local function redistribute()
  if not state.active then
    return
  end

  local left_width, right_width = calculate_margins()

  if left_width == 0 and right_width == 0 then
    M.disable()
    return
  end

  resize_window(state.left_winid, left_width)
  resize_window(state.right_winid, right_width)
end

local function setup_autocmds()
  state.augroup = vim.api.nvim_create_augroup("VimoireFocus", { clear = true })

  vim.api.nvim_create_autocmd("VimResized", {
    group = state.augroup,
    callback = redistribute,
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = state.augroup,
    callback = handle_win_enter,
  })

  -- Fix equalalways damage after window closes (e.g., neotree)
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup,
    callback = function()
      vim.defer_fn(redistribute, 10)
    end,
  })
end

local function teardown_autocmds()
  if state.augroup then
    vim.api.nvim_del_augroup_by_id(state.augroup)
    state.augroup = nil
  end
end

function M.setup()
  config.content_width = vimoire_config.get("editor.textwidth") or 80
end

function M.enable()
  if state.active then
    return
  end

  close_other_windows()

  if not create_margin_windows() then
    return
  end

  state.active = true
  setup_autocmds()
end

function M.disable()
  if not state.active then
    return
  end

  teardown_autocmds()
  destroy_margin_windows()
  state.active = false
end

function M.toggle()
  if state.active then
    M.disable()
  else
    M.enable()
  end
end

function M.is_active()
  return state.active
end

return M
