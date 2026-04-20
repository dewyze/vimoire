local M = {}

M.defaults = {
  colorscheme = "inkwell",
  keymaps = {
    finder = {
      smart = { "<leader>ff", "<C-p>" },
      manuscript = "<leader>fm",
      planning = "<leader>fp",
      snippets = "<leader>fs",
      exports = "<leader>fe",
    },
    navigator = {
      toggle = "<leader>nt",
      reveal = "<leader>nf",
      manuscript = "<leader>nm",
      export = "<leader>ne",
    },
    views = {
      home = "<leader>vh",
      focus = "<leader>vf",
    },
    writing = {
      notes = "<leader>wn",
      marks = "<leader>wm",
      toggle_kind = "<leader>wk",
      prose = "<leader>ww",
    },
    insert = {
      mark = "<leader>im",
      image = "<leader>ii",
    },
    snippets = {
      insert = "<leader>si",
      extract = "<leader>sx",
    },
    comments = {
      create = "<leader>cc",
      edit = "<leader>ce",
      delete = "<leader>cd",
      view = { "<leader>cv", "K" },
      toggle = "<leader>ct",
      list = "<leader>cl",
      next = "]c",
      prev = "[c",
    },
    palette = "<leader>p",
    misc = {
      clear_highlight = { "<Esc><Esc>", "<leader>nh" },
    },
  },
  ui = {
    mouse_mode = "single_click", -- "single_click" | "double_click"
  },
  editor = {
    textwidth = 86,
    scrolloff = 5,
    tabstop = 4,
    shiftwidth = 4,
    wrap = true,
    linebreak = true,
    visual_line_navigation = true,
    typewriter_scrolling = false,
    autosave = false,
    focus_mode = true,
    termguicolors = true,
  },
  stats = {
    reading_wpm = 250,
  },
  finder = {
    preview = true,
  },
  export = {
    auto_open = true,
  },
  comments = {
    visible = true,
    sign = nil, -- nil uses theme sign, set to override (e.g., "●")
  },
  neovide = {
    font = "Iosevka Term Slab:h16",
    linespace = 8,
    padding = {
      top = 20,
      left = 20,
      right = 20,
      bottom = 20,
    },
    scroll_animation_length = 0.3,
  },
}

M._loaded_config = nil
M._user_config = nil

-- Loads user config from ~/.vimoire/config.lua (separate from ~/.config/vimoire/,
-- which is app code via NVIM_APPNAME). Returns {} if the file is missing or invalid.
local function load_user_config()
  if M._user_config then
    return M._user_config
  end

  M._user_config = {}
  local path = vim.fn.expand("~/.vimoire/config.lua")
  if vim.fn.filereadable(path) == 1 then
    local ok, user_config = pcall(dofile, path)
    if ok and type(user_config) == "table" then
      M._user_config = user_config
    end
  end

  return M._user_config
end

function M.load()
  if M._loaded_config then
    return M._loaded_config
  end

  local config = vim.deepcopy(M.defaults)
  config = vim.tbl_deep_extend("force", config, load_user_config())

  M._loaded_config = config
  return config
end

function M.get(key_path)
  local config = M.load()
  local keys = vim.split(key_path, ".", { plain = true })
  local value = config

  for _, key in ipairs(keys) do
    value = value[key]
    if value == nil then
      return nil
    end
  end

  return value
end

-- Returns colorscheme with precedence: user config > preferences > default
function M.effective_colorscheme()
  local user_config = load_user_config()
  if user_config.colorscheme then
    return user_config.colorscheme
  end

  -- Check preferences (set via :Theme)
  local preferences = require("vimoire.preferences")
  local pref_colorscheme = preferences.get("colorscheme")
  if pref_colorscheme then
    return pref_colorscheme
  end

  -- Default
  return M.defaults.colorscheme
end

return M
