local recent = require("vimoire.recent")
local scaffold = require("vimoire.scaffold")

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
    { key = "c", desc = "Config" },
    { key = "x", desc = "Clear recents" },
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
  local ns = vim.api.nvim_create_namespace("vimoire_dashboard")
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
  vim.api.nvim_exec_autocmds("User", { pattern = "VimoireProjectLoaded" })
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
  vim.ui.input({ prompt = "Project name: " }, function(name)
    if not name or name == "" then
      return
    end
    local project_path = parent_path .. "/" .. name .. ".tome"
    scaffold.create(project_path, name)
    open_project(project_path)
  end)
end

local function shorten_home(path)
  return path:gsub("^" .. vim.pesc(vim.fn.expand("~")), "~")
end

local function is_vimoire_project(path)
  return vim.fn.filereadable(path .. "/manuscript.json") == 1
end

local function get_subdirs(path)
  local dirs = {}
  local entries = vim.fn.glob(path .. "/*", false, true)
  for _, entry in ipairs(entries) do
    if vim.fn.isdirectory(entry) == 1 then
      local name = vim.fn.fnamemodify(entry, ":t")
      if not name:match("^%.") then -- skip hidden
        table.insert(dirs, entry)
      end
    end
  end
  table.sort(dirs)
  return dirs
end

local function default_browse_path()
  if #M.projects > 0 then
    return vim.fn.fnamemodify(M.projects[1].path, ":h")
  end
  local docs = vim.fn.expand("~/Documents")
  if vim.fn.isdirectory(docs) == 1 then
    return docs
  end
  return vim.fn.expand("~")
end

-- Generic folder browser with contextual action
-- opts.action_label: function(path) -> string or nil (nil = no action available)
-- opts.on_action: function(path) -> called when action is selected
-- opts.bundle_behavior: "open" to show .tome bundles as openable, nil to hide them
local function browse_folders(start_path, opts)
  local function show_picker(path)
    path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
    local items = {}

    -- Contextual action (if available for this path)
    local action_label = opts.action_label(path)
    if action_label then
      table.insert(items, { type = "action", path = path, display = action_label })
    end

    -- Parent directory
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent ~= path then
      table.insert(items, { type = "nav", path = parent, display = ".." })
    end

    -- Subdirectories
    for _, dir in ipairs(get_subdirs(path)) do
      local name = vim.fn.fnamemodify(dir, ":t")
      local is_project = is_vimoire_project(dir)
      local is_bundle = name:match("%.tome$")

      if is_project and opts.bundle_behavior == "open" then
        table.insert(items, { type = "action", path = dir, display = name .. " ★" })
      elseif is_bundle then
        -- Hide .tome bundles in non-open contexts (don't create inside one)
      else
        local marker = is_project and " ★" or ""
        table.insert(items, { type = "nav", path = dir, display = name .. "/" .. marker })
      end
    end

    vim.ui.select(items, {
      prompt = shorten_home(path),
      format_item = function(item)
        return item.display
      end,
    }, function(choice)
      if not choice then
        return
      end
      if choice.type == "action" then
        opts.on_action(choice.path)
      else
        show_picker(choice.path)
      end
    end)
  end

  show_picker(start_path)
end

local function new_project()
  browse_folders(default_browse_path(), {
    action_label = function(_)
      return "[Create project here]"
    end,
    on_action = function(path)
      create_project_at(path)
    end,
  })
end

local function browse_project()
  browse_folders(default_browse_path(), {
    bundle_behavior = "open",
    action_label = function(path)
      if is_vimoire_project(path) then
        return "[Open this project]"
      end
      return nil
    end,
    on_action = function(path)
      open_project(path)
    end,
  })
end

local function open_config()
  local config_path = vim.fn.expand("~/.vimoire/config.lua")
  local config_dir = vim.fn.expand("~/.vimoire")

  -- Create directory and file if they don't exist
  if vim.fn.isdirectory(config_dir) == 0 then
    vim.fn.mkdir(config_dir, "p")
  end
  if vim.fn.filereadable(config_path) == 0 then
    vim.fn.writefile({ "-- Vimoire user configuration", "-- See docs/CONFIGURATION.md for options", "", "return {}", "" }, config_path)
  end

  M.hide()
  vim.cmd("edit " .. config_path)
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
  vim.keymap.set("n", "c", open_config, opts)
  vim.keymap.set("n", "x", function()
    recent.clear()
    M.selected_index = 1
    render()
  end, opts)
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
  vim.api.nvim_buf_set_name(M.buf, "vimoire://dashboard")

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
