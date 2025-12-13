local recent = require("vimoire.core.recent")
local scaffold = require("vimoire.core.scaffold")

local M = {}

M.buf = nil
M.win = nil
M.selected_index = 1
M.projects = {}

local LOGO = {
  "██╗   ██╗██╗███╗   ███╗ ██████╗ ██╗██████╗ ███████╗",
  "██║   ██║██║████╗ ████║██╔═══██╗██║██╔══██╗██╔════╝",
  "██║   ██║██║██╔████╔██║██║   ██║██║██████╔╝█████╗  ",
  "╚██╗ ██╔╝██║██║╚██╔╝██║██║   ██║██║██╔══██╗██╔══╝  ",
  " ╚████╔╝ ██║██║ ╚═╝ ██║╚██████╔╝██║██║  ██║███████╗",
  "  ╚═══╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝",
}

local TAGLINE = "a grimoire for vim"

-- Highlights are defined in vimoire/highlights.lua (fallbacks)
-- and overridden by colorschemes in colors/*.lua

local function center_text(text, width)
  local padding = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
  return string.rep(" ", math.max(0, padding)) .. text
end

local function format_date(timestamp)
  local now = os.time()
  local diff = now - timestamp

  if diff < 86400 then
    return "today"
  elseif diff < 172800 then
    return "yesterday"
  elseif diff < 604800 then
    return math.floor(diff / 86400) .. " days ago"
  else
    return os.date("%b %d", timestamp)
  end
end

local function shorten_path(path, max_len)
  if #path <= max_len then
    return path
  end
  local home = vim.fn.expand("~")
  path = path:gsub("^" .. vim.pesc(home), "~")
  if #path <= max_len then
    return path
  end
  return "..." .. path:sub(-(max_len - 3))
end

local function render()
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
    return
  end

  local width = vim.api.nvim_win_get_width(M.win or 0)
  local lines = {}
  local highlights = {}

  -- Stars and spacing at top
  table.insert(lines, "")
  table.insert(lines, center_text("·          ✧                    ·", width))
  table.insert(highlights, { line = #lines - 1, col = 0, text = lines[#lines], hl = "VimoireStar" })
  table.insert(lines, "")
  table.insert(lines, center_text("✦                          ·                   ✧", width))
  table.insert(highlights, { line = #lines - 1, col = 0, text = lines[#lines], hl = "VimoireStar" })
  table.insert(lines, center_text("✦", width))
  table.insert(highlights, { line = #lines - 1, col = 0, text = lines[#lines], hl = "VimoireStar" })
  table.insert(lines, "")

  -- Logo
  for _, logo_line in ipairs(LOGO) do
    local centered = center_text(logo_line, width)
    table.insert(lines, centered)
    table.insert(highlights, { line = #lines - 1, col = 0, text = centered, hl = "VimoireLogo" })
  end

  table.insert(lines, "")
  local tagline_centered = center_text(TAGLINE, width)
  table.insert(lines, tagline_centered)
  table.insert(highlights, { line = #lines - 1, col = 0, text = tagline_centered, hl = "VimoireTagline" })

  -- More stars
  table.insert(lines, "")
  table.insert(lines, center_text("·              ✧               ·            ✦", width))
  table.insert(highlights, { line = #lines - 1, col = 0, text = lines[#lines], hl = "VimoireStar" })
  table.insert(lines, "")
  table.insert(lines, "")

  -- Recent Projects section
  M.projects = recent.list()
  local projects_start_line = #lines

  if #M.projects > 0 then
    local header = center_text("Recent Projects", width)
    table.insert(lines, header)
    table.insert(highlights, { line = #lines - 1, col = 0, text = header, hl = "VimoireHeader" })
    table.insert(lines, "")

    M.first_project_line = #lines

    for i, project in ipairs(M.projects) do
      local prefix = i == M.selected_index and "▸ " or "  "
      local date_str = format_date(project.last_opened)
      local path_str = shorten_path(project.path, 30)

      local project_line = prefix .. project.title .. "  " .. path_str .. "  (" .. date_str .. ")"

      table.insert(lines, center_text(project_line, width))
      local hl = i == M.selected_index and "VimoireProjectSelected" or "VimoireProject"
      table.insert(highlights, { line = #lines - 1, col = 0, text = lines[#lines], hl = hl })
    end
  else
    local no_projects = center_text("No recent projects", width)
    table.insert(lines, no_projects)
    table.insert(highlights, { line = #lines - 1, col = 0, text = no_projects, hl = "VimoirePath" })
    M.first_project_line = nil
  end

  table.insert(lines, "")
  table.insert(lines, "")

  -- Actions
  local actions_header = center_text("Actions", width)
  table.insert(lines, actions_header)
  table.insert(highlights, { line = #lines - 1, col = 0, text = actions_header, hl = "VimoireHeader" })
  table.insert(lines, "")

  local actions = {
    { key = "n", desc = "New project" },
    { key = "b", desc = "Browse for project" },
    { key = "q", desc = "Quit" },
  }

  for _, action in ipairs(actions) do
    local action_line = center_text("[" .. action.key .. "] " .. action.desc, width)
    table.insert(lines, action_line)
    -- We'd need more complex highlighting here for the key vs desc
    table.insert(highlights, { line = #lines - 1, col = 0, text = action_line, hl = "VimoireAction" })
  end

  table.insert(lines, "")
  table.insert(lines, center_text("·            ✧              ·", width))
  table.insert(highlights, { line = #lines - 1, col = 0, text = lines[#lines], hl = "VimoireStar" })

  -- Write to buffer
  vim.api.nvim_buf_set_option(M.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M.buf, "modifiable", false)

  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("vimoire_start_screen")
  vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(M.buf, ns, hl.hl, hl.line, 0, -1)
  end
end

local function move_selection(delta)
  if #M.projects == 0 then
    return
  end
  M.selected_index = M.selected_index + delta
  if M.selected_index < 1 then
    M.selected_index = #M.projects
  elseif M.selected_index > #M.projects then
    M.selected_index = 1
  end
  render()
end

local function open_project(path)
  M.hide()
  local state = require("vimoire.state")
  state:load(path)
  require("vimoire.setup").on_manuscript_loaded()
end

local function open_selected()
  if #M.projects == 0 then
    return
  end
  local project = M.projects[M.selected_index]
  if project then
    open_project(project.path)
  end
end

local function create_project_at(parent_path)
  vim.ui.input({ prompt = "Project folder name: " }, function(folder_name)
    if not folder_name or folder_name == "" then
      return
    end
    vim.ui.input({ prompt = "Book title: " }, function(title)
      if not title or title == "" then
        return
      end
      local project_path = parent_path .. "/" .. folder_name
      scaffold.create(project_path, title)
      open_project(project_path)
    end)
  end)
end

local function default_browse_path()
  if #M.projects > 0 then
    return vim.fn.fnamemodify(M.projects[1].path, ":h")
  end
  return vim.fn.expand("~")
end

local function new_project()
  local telescope = require("telescope")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  telescope.extensions.file_browser.file_browser({
    prompt_title = "Select parent folder",
    path = default_browse_path(),
    hidden = false,
    respect_gitignore = false,
    files = false,
    sorting_strategy = "ascending",
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local parent_path = selection.path or selection[1]
          create_project_at(parent_path)
        end
      end)
      return true
    end,
  })
end

local function browse_project()
  local telescope = require("telescope")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  telescope.extensions.file_browser.file_browser({
    prompt_title = "Select project folder",
    path = default_browse_path(),
    hidden = false,
    respect_gitignore = false,
    files = false,
    sorting_strategy = "ascending",
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local path = selection.path or selection[1]
          open_project(path)
        end
      end)
      return true
    end,
  })
end

local function setup_keymaps()
  local opts = { buffer = M.buf, nowait = true, silent = true }

  vim.keymap.set("n", "j", function()
    move_selection(1)
  end, opts)
  vim.keymap.set("n", "<Down>", function()
    move_selection(1)
  end, opts)
  vim.keymap.set("n", "k", function()
    move_selection(-1)
  end, opts)
  vim.keymap.set("n", "<Up>", function()
    move_selection(-1)
  end, opts)
  vim.keymap.set("n", "<CR>", open_selected, opts)
  vim.keymap.set("n", "n", new_project, opts)
  vim.keymap.set("n", "b", browse_project, opts)
  vim.keymap.set("n", "q", function()
    vim.cmd("quit")
  end, opts)
end

function M.show()
  -- Create buffer
  M.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(M.buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(M.buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(M.buf, "swapfile", false)
  vim.api.nvim_buf_set_name(M.buf, "vimoire://start")

  -- Use current window
  M.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.win, M.buf)

  -- Window options
  vim.api.nvim_win_set_option(M.win, "number", false)
  vim.api.nvim_win_set_option(M.win, "relativenumber", false)
  vim.api.nvim_win_set_option(M.win, "signcolumn", "no")
  vim.api.nvim_win_set_option(M.win, "cursorline", false)

  M.selected_index = 1
  setup_keymaps()
  render()
end

function M.hide()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
  end
  M.buf = nil
  M.win = nil
end

return M
