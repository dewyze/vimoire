local M = {}

M.defaults = {
  ui = {
    mouse_mode = "single_click", -- "single_click" | "double_click"
  },
  navigator = {
    keybinding = "<LocalLeader>nt",
    colors = {
      manuscript = "#c792ea",
      section = "#82aaff",
      chapter = "#89ddff",
      planning = "#f78c6c",
      planning_subfolder = "#ff9e64",
      planning_item = "#ffc79b",
      winbar = "#a3d9a5",
    },
  },
  editor = {
    textwidth = 80,
    scrolloff = 5,
    tabstop = 4,
    shiftwidth = 4,
    wrap = true,
    linebreak = true,
  },
  finder = {
    preview = true,
  },
  neovide = {
    font = "Iosevka Term Slab:h15",
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

  -- TODO: Load user config from ~/.config/vimoire/config.lua
  -- local user_config_path = vim.fn.expand("~/.config/vimoire/config.lua")
  -- if vim.fn.filereadable(user_config_path) == 1 then
  --   local ok, user_config = pcall(dofile, user_config_path)
  --   if ok then
  --     config = vim.tbl_deep_extend("force", config, user_config)
  --   end
  -- end

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

return M
