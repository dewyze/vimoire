local state = {
  manuscript = nil,
  book = nil,
  items = {},
  paths = {},
}

-- Walk a tree of item data tables.
-- visit(data, items, ctx) -> (children_to_recurse_into_or_nil, ctx_for_children)
local function walk(items, ctx, visit)
  for _, data in ipairs(items or {}) do
    local children, child_ctx = visit(data, items, ctx)
    if children then
      walk(children, child_ctx, visit)
    end
  end
end

local Manuscript = require("vimoire.core.manuscript")
local Book = require("vimoire.core.book")
local orphan = require("vimoire.core.orphan")
local Entry = require("vimoire.core.entry")
local Item = require("vimoire.core.item")
local Folder = require("vimoire.core.folder")
local ExportFile = require("vimoire.core.export_file")
local Board = require("vimoire.plotting.board")
local add_options = require("vimoire.core.add_options")

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

function state:register(item)
  self.items[item.id] = item
  local text_path = item:text_path()
  if text_path then
    self.paths[vim.fn.fnamemodify(text_path, ":p")] = item
  end
  local notes_path = item:notes_path()
  if notes_path then
    self.paths[vim.fn.fnamemodify(notes_path, ":p")] = item
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
  end

  -- Folders (synthetic UI containers)
  self.items["manuscript"] = Folder.new("manuscript", "Manuscript", "manuscript", self.manuscript.items, {
    add_options = { add_options.SECTION, add_options.CHAPTER, add_options.PAGE },
  })
  self.items["planning"] = Folder.new("planning", "Planning", "planning", {
    { id = "characters" },
    { id = "settings" },
    { id = "reference" },
    { id = "orphaned_notes" },
  })
  self.items["characters"] = Folder.new("characters", "Characters", "characters", self.manuscript.characters or {}, {
    add_options = { add_options.PLANNING_ITEM },
  })
  self.items["settings"] = Folder.new("settings", "Settings", "settings", self.manuscript.settings or {}, {
    add_options = { add_options.PLANNING_ITEM },
  })
  self.items["reference"] = Folder.new("reference", "Reference", "reference", self.manuscript.reference or {}, {
    add_options = { add_options.PLANNING_ITEM, add_options.SUBFOLDER },
  })
  self.items["orphaned_notes"] = Folder.new("orphaned_notes", "Orphaned Notes", "orphaned_notes", self.manuscript.orphaned_notes or {})

  -- Export section (filesystem-backed)
  local templates_items = ExportFile.scan_folder(self, "export_templates", root .. "/exports/templates")
  local configs_items = ExportFile.scan_folder(self, "export_configs", root .. "/exports/configs")
  local output_items = ExportFile.scan_folder(self, "export_output", root .. "/exports/output")

  self.items["export"] = Folder.new("export", "Export", "export", {
    { id = "export_templates" },
    { id = "export_configs" },
    { id = "export_output" },
  })
  self.items["export_templates"] = Folder.new("export_templates", "Templates", "export_folder", templates_items)
  self.items["export_configs"] = Folder.new("export_configs", "Configs", "export_folder", configs_items)
  self.items["export_output"] = Folder.new("export_output", "Output", "export_folder", output_items)

  -- Plotting section (filesystem-backed)
  local plotting_items = Board.scan_folder(self, root .. "/plotting")
  self.items["plotting"] = Folder.new("plotting", "Plotting", "plotting", plotting_items, {
    add_options = { add_options.PLOTTING_BOARD },
  })

  -- Process manuscript entries
  local function visit_manuscript(data, items, parent_section)
    local item = Entry.build(data, root)
    item.parent_items = items
    item.parent_section = parent_section
    self:register(item)
    if item.items then
      return item.items, item
    end
    if item:numbered() then
      chapter_count = chapter_count + 1
      item.chapter_index = chapter_count
    end
  end

  walk(self.manuscript.items, nil, visit_manuscript)

  -- Process planning items
  local function visit_planning(data, items)
    local item
    if data.items then
      item = Item.new("subfolder", data, root)
    else
      item = Item.new("planning_item", data, root)
    end
    item.parent_items = items
    self:register(item)
    return data.items
  end

  for _, list in ipairs({
    self.manuscript.characters,
    self.manuscript.settings,
    self.manuscript.reference,
    self.manuscript.orphaned_notes,
  }) do
    walk(list, nil, visit_planning)
  end
end

return state
