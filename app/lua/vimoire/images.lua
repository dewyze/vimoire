local Path = require("plenary.path")

local M = {}

M.IMAGE_EXTENSIONS = { "png", "jpg", "jpeg", "gif", "webp", "svg" }

local function is_image(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then return false end
  ext = ext:lower()
  return vim.tbl_contains(M.IMAGE_EXTENSIONS, ext)
end

function M.dir(root)
  return root .. "/assets/images"
end

function M.full_path(root, filename)
  return M.dir(root) .. "/" .. filename
end

function M.list(root)
  local dir_path = M.dir(root)
  local path = Path:new(dir_path)

  if not path:exists() then
    return {}
  end

  local files = vim.fn.readdir(dir_path)
  local images = {}

  for _, file in ipairs(files) do
    if is_image(file) then
      table.insert(images, file)
    end
  end

  return images
end

function M.exists(root, filename)
  local path = Path:new(M.full_path(root, filename))
  return path:exists()
end

function M.copy(root, src_path)
  local src = Path:new(src_path)
  if not src:exists() then
    return nil
  end

  local dir_path = M.dir(root)
  Path:new(dir_path):mkdir({ parents = true })

  local filename = vim.fn.fnamemodify(src_path, ":t")
  local dest_path = M.full_path(root, filename)

  vim.fn.system({ "cp", src_path, dest_path })

  return dest_path
end

function M.delete(root, filename)
  local path = Path:new(M.full_path(root, filename))

  if not path:exists() then
    return false
  end

  path:rm()
  return true
end

function M.rename(root, old_filename, new_filename)
  local old_path = Path:new(M.full_path(root, old_filename))
  local new_path = M.full_path(root, new_filename)

  if not old_path:exists() then
    return false, "File not found"
  end

  if Path:new(new_path):exists() then
    return false, "File already exists"
  end

  old_path:rename({ new_name = new_path })
  return true
end

-- File browser helpers

local function shorten_home(path)
  return path:gsub("^" .. vim.pesc(vim.fn.expand("~")), "~")
end

local function get_entries(path)
  local dirs = {}
  local files = {}
  local entries = vim.fn.glob(path .. "/*", false, true)

  for _, entry in ipairs(entries) do
    local name = vim.fn.fnamemodify(entry, ":t")
    if not name:match("^%.") then -- skip hidden
      if vim.fn.isdirectory(entry) == 1 then
        table.insert(dirs, entry)
      elseif is_image(name) then
        table.insert(files, entry)
      end
    end
  end

  table.sort(dirs)
  table.sort(files)
  return dirs, files
end

local function default_browse_path()
  local pictures = vim.fn.expand("~/Pictures")
  if vim.fn.isdirectory(pictures) == 1 then
    return pictures
  end
  local downloads = vim.fn.expand("~/Downloads")
  if vim.fn.isdirectory(downloads) == 1 then
    return downloads
  end
  return vim.fn.expand("~")
end

-- Browse filesystem for an image file
-- on_select(image_path) called when user picks an image
function M.browse(on_select)
  local function show_picker(path)
    path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
    local items = {}

    -- Parent directory
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent ~= path then
      table.insert(items, { type = "dir", path = parent, display = ".." })
    end

    -- Subdirectories and image files
    local dirs, files = get_entries(path)

    for _, dir in ipairs(dirs) do
      local name = vim.fn.fnamemodify(dir, ":t")
      table.insert(items, { type = "dir", path = dir, display = name .. "/" })
    end

    for _, file in ipairs(files) do
      local name = vim.fn.fnamemodify(file, ":t")
      table.insert(items, { type = "file", path = file, display = name })
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
      if choice.type == "dir" then
        show_picker(choice.path)
      else
        on_select(choice.path)
      end
    end)
  end

  show_picker(default_browse_path())
end

-- Copy image to assets with collision handling
-- Returns final destination path, or nil if cancelled
function M.copy_with_collision_handling(root, src_path, on_complete)
  local filename = vim.fn.fnamemodify(src_path, ":t")

  if not M.exists(root, filename) then
    local dest = M.copy(root, src_path)
    on_complete(dest)
    return
  end

  -- File exists, ask what to do
  vim.ui.select({ "Overwrite", "Rename", "Cancel" }, {
    prompt = filename .. " already exists:",
  }, function(choice)
    if choice == "Overwrite" then
      local dest = M.copy(root, src_path)
      on_complete(dest)
    elseif choice == "Rename" then
      vim.ui.input({ prompt = "New filename: " }, function(new_name)
        if new_name and new_name ~= "" then
          local dir_path = M.dir(root)
          Path:new(dir_path):mkdir({ parents = true })
          local dest_path = M.full_path(root, new_name)
          vim.fn.system({ "cp", src_path, dest_path })
          on_complete(dest_path)
        else
          on_complete(nil)
        end
      end)
    else
      on_complete(nil)
    end
  end)
end

-- Generate markdown image syntax
function M.markdown(filename, alt_text)
  alt_text = alt_text or ""
  return string.format("![%s](assets/images/%s)", alt_text, filename)
end

-- Insert markdown at cursor position
function M.insert_at_cursor(text)
  local lines = vim.split(text, "\n")
  vim.api.nvim_put(lines, "c", true, true)
end

function M.insert()
  local state = require("vimoire.state")
  local Snacks = require("snacks")

  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local root = state.manuscript.root

  local function insert_from_file()
    M.browse(function(src_path)
      M.copy_with_collision_handling(root, src_path, function(dest_path)
        if not dest_path then
          return
        end

        local filename = vim.fn.fnamemodify(dest_path, ":t")

        vim.ui.input({ prompt = "Alt text: " }, function(alt_text)
          local md = M.markdown(filename, alt_text or "")
          M.insert_at_cursor(md)
        end)
      end)
    end)
  end

  local function insert_from_assets()
    local image_list = M.list(root)

    if #image_list == 0 then
      vim.notify("No images in assets/images/", vim.log.levels.INFO)
      return
    end

    local picker_items = {}
    for _, filename in ipairs(image_list) do
      table.insert(picker_items, {
        text = filename,
        filename = filename,
        path = M.full_path(root, filename),
      })
    end

    Snacks.picker({
      title = "Images",
      items = picker_items,
      preview = false,
      format = function(item)
        return { { item.text, "Normal" } }
      end,
      actions = {
        delete_image = function(picker)
          local sel = picker:current()
          if sel and sel.filename then
            M.delete(root, sel.filename)
            vim.notify("Deleted " .. sel.filename, vim.log.levels.INFO)
            picker:close()
          end
        end,
        rename_image = function(picker)
          local sel = picker:current()
          if sel and sel.filename then
            vim.ui.input({ prompt = "New filename: ", default = sel.filename }, function(new_name)
              if new_name and new_name ~= "" and new_name ~= sel.filename then
                local ok, err = M.rename(root, sel.filename, new_name)
                if ok then
                  vim.notify("Renamed to " .. new_name, vim.log.levels.INFO)
                else
                  vim.notify(err or "Rename failed", vim.log.levels.ERROR)
                end
              end
              picker:close()
            end)
          end
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-d>"] = { "delete_image", mode = { "n", "i" }, desc = "Delete" },
            ["<C-r>"] = { "rename_image", mode = { "n", "i" }, desc = "Rename" },
          },
          footer_keys = { "<C-d>", "<C-r>" },
        },
      },
      confirm = function(picker, selected)
        if selected and selected.filename then
          picker:close()
          vim.ui.input({ prompt = "Alt text: " }, function(alt_text)
            local md = M.markdown(selected.filename, alt_text or "")
            M.insert_at_cursor(md)
          end)
        end
      end,
    })
  end

  vim.ui.select({ "From file", "From assets" }, {
    prompt = "Insert image:",
  }, function(choice)
    if choice == "From file" then
      insert_from_file()
    elseif choice == "From assets" then
      insert_from_assets()
    end
  end)
end

return M
