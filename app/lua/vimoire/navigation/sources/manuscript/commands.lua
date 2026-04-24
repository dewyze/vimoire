local cc = require("neo-tree.sources.common.commands")
local vimoire_state = require("vimoire.state")
local movement = require("vimoire.core.movement")
local delete_options = require("vimoire.core.delete_options")
local add_options = require("vimoire.core.add_options")
local rename = require("vimoire.core.rename")
local select = require("vimoire.util.select")

local M = {}

-- Explicit assignments for neo-tree validation
M.open_split = cc.open_split
M.open_vsplit = cc.open_vsplit
M.toggle_node = cc.toggle_node
M.close_node = cc.close_node
M.close_all_nodes = cc.close_all_nodes
M.expand_all_nodes = cc.expand_all_nodes
M.close_window = cc.close_window
M.show_help = cc.show_help

function M.refresh(state, focus_id)
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name, function()
    if focus_id then
      local renderer = require("neo-tree.ui.renderer")
      renderer.focus_node(state, focus_id)
    end
  end)
end

function M.open(state)
  local node = state.tree:get_node()

  -- Items with a custom action handle their own open (e.g., external opener for binaries)
  if node.extra and node.extra.action and node.extra.action() then
    return
  end

  -- Items with a path fall through to neo-tree's open (handles window management)
  if node.path then
    cc.open(state, cc.toggle_node)
    return
  end

  cc.toggle_node(state)
end

function M.notes(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end
  if item.open_notes then item:open_notes() end
end

function M.delete_notes(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end
  if not item.delete_notes then return end

  local notes = item:notes_path()
  if not notes or not require("plenary.path"):new(notes):exists() then return end

  local choice = vim.fn.confirm("Delete notes for " .. item:display_name() .. "?", "&Yes\n&No", 2)
  if choice == 1 and item:delete_notes() then
    M.refresh(state, item.id)
  end
end

function M.add(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local options = item:add_options()
  if not options then return end

  local labels = add_options.labels(options)

  select.select(labels, {
    prompt = "Add:",
    snacks = { layout = { hidden = { "input" }, preview = false } },
  }, function(choice)
    if not choice then return end
    local opt = add_options.find_by_label(options, choice)
    if not opt then return end

    vim.ui.input({
      prompt = "Name: ",
    }, function(name)
      if not name or name:match("^%s*$") then return end

      local parent_items, at_index
      if opt.target then
        parent_items, at_index = opt.target(vimoire_state, item)
      else
        parent_items = item:add_parent_items()
        at_index = item:add_index()
      end

      local new_item = opt.execute(vimoire_state, name, parent_items, at_index)
      if new_item then
        M.refresh(state, new_item.id)
      end
    end)
  end)
end

function M.rename(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  vim.ui.input({
    prompt = "Rename: ",
    default = item.name,
  }, function(new_name)
    if not new_name then return end

    local ok, err = rename.execute(item, vimoire_state, new_name)
    if ok then
      M.refresh(state, item.id)
    else
      vim.notify(err, vim.log.levels.ERROR)
    end
  end)
end

function M.delete(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local result = delete_options.for_item(item)
  if not result then return end

  if result.confirm then
    local ok, choice = pcall(vim.fn.confirm, "Delete " .. item:display_name() .. "?", "&Yes\n&No", 2)
    if ok and choice == 1 and result.confirm.execute(item, vimoire_state) then
      M.refresh(state)
    end
  elseif result.choose then
    local labels = delete_options.labels(result.choose, item)
    select.select(labels, {
      prompt = "Delete " .. item:display_name() .. "?",
      snacks = { layout = { hidden = { "input" }, preview = false } },
    }, function(choice)
      local opt = delete_options.find_by_label(result.choose, choice, item)
      if opt and opt.execute(item, vimoire_state) then
        M.refresh(state)
      end
    end)
  end
end

function M.move(state)
  vim.notify("Move not yet implemented", vim.log.levels.INFO)
end

function M.move_up(state)
  local node = state.tree:get_node()
  local id = node.id
  if id and movement.move_up(vimoire_state, id) then
    M.refresh(state, id)
  end
end

function M.move_down(state)
  local node = state.tree:get_node()
  local id = node.id
  if id and movement.move_down(vimoire_state, id) then
    M.refresh(state, id)
  end
end

function M.toggle_kind(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local ok, err = item:toggle(vimoire_state)
  if ok then
    M.refresh(state, item.id)
  else
    vim.notify(err, vim.log.levels.WARN)
  end
end

return M
