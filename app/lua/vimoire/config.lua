local M = {}

M.defaults = {
  colorscheme = "inkwell",
  keymaps = {
    finder = {
      smart = "<leader>ff",
      smart_alt = "<C-p>",
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
    misc = {
      clear_highlight = "<Esc><Esc>",
      save = "<D-s>",
      copy = "<D-c>",
      paste = "<D-v>",
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
    autosave = false,
    focus_mode = true,
  },
  finder = {
    preview = true,
  },
  export = {
    auto_open = true,
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

function M.load()
  if M._loaded_config then
    return M._loaded_config
  end

  local config = vim.deepcopy(M.defaults)

  -- Load user config from ~/.vimoire/config.lua
  -- This is separate from ~/.config/vimoire/ (app code via NVIM_APPNAME)
  local user_config_path = vim.fn.expand("~/.vimoire/config.lua")
  if vim.fn.filereadable(user_config_path) == 1 then
    local ok, user_config = pcall(dofile, user_config_path)
    if ok and type(user_config) == "table" then
      config = vim.tbl_deep_extend("force", config, user_config)
    end
  end

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
  -- Check if user config explicitly sets colorscheme
  local user_config_path = vim.fn.expand("~/.vimoire/config.lua")
  if vim.fn.filereadable(user_config_path) == 1 then
    local ok, user_config = pcall(dofile, user_config_path)
    if ok and type(user_config) == "table" and user_config.colorscheme then
      return user_config.colorscheme
    end
  end

  -- Check preferences (set via :Theme)
  local preferences = require("vimoire.core.preferences")
  local pref_colorscheme = preferences.get("colorscheme")
  if pref_colorscheme then
    return pref_colorscheme
  end

  -- Default
  return M.defaults.colorscheme
end

return M
