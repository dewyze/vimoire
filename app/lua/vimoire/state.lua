local state = {
  manuscript = nil,
  book = nil,
  items = {},
  paths = {},
}

local Manuscript = require("vimoire.core.manuscript")
local Book = require("vimoire.core.book")
local orphan = require("vimoire.core.orphan")
local Entry = require("vimoire.core.entry")
local PlanningSection = require("vimoire.core.planning_section")
local PlanningItem = require("vimoire.core.planning_item")
local Folder = require("vimoire.core.folder")
local ExportFile = require("vimoire.core.export_file")
local view_config = require("vimoire.view.config")

local function apply_view(item)
  local config = view_config[item.kind] or {}
  item.add_options = config.add_options
  item.immutable = config.immutable or false
end

function state:load(manuscript_path)
  self.manuscript = Manuscript.load(manuscript_path)
  self.book = Book.load(manuscript_path)

  -- Detect and recover orphaned entries
  local recovered = orphan.recover(self.manuscript)
  if #recovered > 0 then
    self.manuscript:save()
    local msg = "Recovered " .. #recovered .. " orphaned entries:\n- " .. table.concat(recovered, "\n- ")
    vim.notify(msg, vim.log.levels.INFO)
  end

  self:rebuild()
end

function state:save()
  self.manuscript:save()
  self:rebuild()
end

local function register_path(state, item)
  local text_path = item:text_path()
  if text_path then
    state.paths[vim.fn.fnamemodify(text_path, ":p")] = item
  end
  local notes_path = item:notes_path()
  if notes_path then
    state.paths[vim.fn.fnamemodify(notes_path, ":p")] = item
  end
end

function state:rebuild()
  self.items = {}
  self.paths = {}

  if not self.manuscript then
    return
  end

  local root = self.manuscript.root
  local chapter_count = 0

  -- Book metadata node
  if self.book then
    self.items[self.book.id] = self.book
    apply_view(self.book)
  end

  -- Folders (synthetic UI containers)
  self.items["manuscript"] = Folder.new("manuscript", "Manuscript", "manuscript", self.manuscript.items)
  self.items["planning"] = Folder.new("planning", "Planning", "planning", {
    { id = "characters" },
    { id = "settings" },
    { id = "reference" },
    { id = "orphaned_notes" },
  })
  self.items["characters"] = Folder.new("characters", "Characters", "characters", self.manuscript.characters or {})
  self.items["settings"] = Folder.new("settings", "Settings", "settings", self.manuscript.settings or {})
  self.items["reference"] = Folder.new("reference", "Reference", "reference", self.manuscript.reference or {})
  self.items["orphaned_notes"] = Folder.new("orphaned_notes", "Orphaned Notes", "orphaned_notes", self.manuscript.orphaned_notes or {})

  -- Export section (filesystem-backed)
  local function scan_export_dir(folder_id, dir_path)
    local items = {}
    local handle = vim.loop.fs_scandir(dir_path)
    if handle then
      while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then
          break
        end
        if type == "file" then
          local file_id = folder_id .. ":" .. name
          local file_path = dir_path .. "/" .. name
          local file = ExportFile.new(file_id, name, file_path)
          file.parent_items = items
          apply_view(file)
          self.items[file_id] = file
          table.insert(items, { id = file_id })
        end
      end
    end
    table.sort(items, function(a, b)
      return a.id < b.id
    end)
    return items
  end

  local templates_items = scan_export_dir("export_templates", root .. "/exports/templates")
  local configs_items = scan_export_dir("export_configs", root .. "/exports/configs")
  local output_items = scan_export_dir("export_output", root .. "/exports/output")

  self.items["export"] = Folder.new("export", "Export", "export", {
    { id = "export_templates" },
    { id = "export_configs" },
    { id = "export_output" },
  })
  self.items["export_templates"] = Folder.new("export_templates", "Templates", "export_folder", templates_items)
  self.items["export_configs"] = Folder.new("export_configs", "Configs", "export_folder", configs_items)
  self.items["export_output"] = Folder.new("export_output", "Output", "export_folder", output_items)

  -- Apply view config to folders
  for _, id in ipairs({ "manuscript", "planning", "characters", "settings", "reference", "orphaned_notes", "export", "export_templates", "export_configs", "export_output" }) do
    apply_view(self.items[id])
  end

  -- Process manuscript entries
  local function process_items(items, parent_section)
    for _, item_data in ipairs(items) do
      local item = Entry.build(item_data, root)
      item.parent_items = items
      item.parent_section = parent_section
      apply_view(item)
      self.items[item.id] = item
      register_path(self, item)

      if item.items then
        process_items(item.items, item)
      elseif item.kind == "chapter" then
        chapter_count = chapter_count + 1
        item.chapter_index = chapter_count
      end
    end
  end

  process_items(self.manuscript.items or {}, nil)

  -- Process planning items
  local function process_planning(items, parent_items)
    for _, data in ipairs(items or {}) do
      local item
      if data.items then
        item = PlanningSection.new(data, root)
      else
        item = PlanningItem.new(data, root)
      end
      item.parent_items = parent_items
      apply_view(item)
      self.items[data.id] = item
      register_path(self, item)

      if data.items then
        process_planning(data.items, data.items)
      end
    end
  end

  process_planning(self.manuscript.characters, self.manuscript.characters)
  process_planning(self.manuscript.settings, self.manuscript.settings)
  process_planning(self.manuscript.reference, self.manuscript.reference)
  if self.manuscript.orphaned_notes then
    process_planning(self.manuscript.orphaned_notes, self.manuscript.orphaned_notes)
  end
end

return state
