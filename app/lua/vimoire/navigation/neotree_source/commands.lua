local M = {}
local cc = require("neo-tree.sources.common.commands")
local vimoire_state = require("vimoire.state")
local movement = require("vimoire.core.movement")
local delete_options = require("vimoire.core.delete_options")
local add_options = require("vimoire.core.add_options")
local rename = require("vimoire.core.rename")
local open = require("vimoire.navigation.open")

-- Custom: refresh tree
M.refresh = function(state, focus_id)
  local manager = require("neo-tree.sources.manager")
  manager.refresh(state.name, function()
    if focus_id then
      local renderer = require("neo-tree.ui.renderer")
      renderer.focus_node(state, focus_id)
    end
  end)
end

-- Custom: open file or toggle folder
M.open = function(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if item and item:text_path() then
    open.open_item(item)
  else
    cc.toggle_node(state)
  end
end

-- Custom: open notes
M.notes = function(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local notes_path = item:notes_path()
  if not notes_path then return end

  vim.cmd("edit " .. notes_path)
  vim.b.vimoire_item_id = item.id
end

-- From common: navigation
M.open_split = cc.open_split
M.open_vsplit = cc.open_vsplit
M.toggle_node = cc.toggle_node
M.close_node = cc.close_node
M.close_all_nodes = cc.close_all_nodes
M.expand_all_nodes = cc.expand_all_nodes

-- From common: window
M.close_window = cc.close_window
M.show_help = cc.show_help

-- Custom: add (context-aware)
M.add = function(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local options = item.add_options
  if not options then return end

  local labels = add_options.labels(options)

  vim.ui.select(labels, {
    prompt = "Add:",
  }, function(choice)
    local opt = add_options.find_by_label(options, choice)
    if not opt or opt == add_options.CANCEL then return end

    vim.ui.input({
      prompt = "Name: ",
    }, function(name)
      if not name or name:match("^%s*$") then return end

      local parent_items = item:add_parent_items()
      local at_index = item:add_index()
      local new_item = opt.execute(vimoire_state, name, parent_items, at_index)
      if new_item then
        M.refresh(state, new_item.id)
      end
    end)
  end)
end

-- Custom: rename
M.rename = function(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  vim.ui.input({
    prompt = "Rename: ",
    default = item.name,
  }, function(new_name)
    if not new_name then return end -- cancelled

    local ok, err = rename.execute(item, vimoire_state, new_name)
    if ok then
      M.refresh(state, item.id)
    else
      vim.notify(err, vim.log.levels.ERROR)
    end
  end)
end

-- Custom: delete
M.delete = function(state)
  local node = state.tree:get_node()
  local item = vimoire_state.items[node.id]
  if not item then return end

  local options = delete_options.options_for(item)
  if not options then return end

  local labels = delete_options.labels(options, item)

  vim.ui.select(labels, {
    prompt = "Delete " .. item:display_name() .. "?",
  }, function(choice)
    local opt = delete_options.find_by_label(options, choice, item)
    if opt and opt.execute(item, vimoire_state) then
      M.refresh(state)
    end
  end)
end

-- Custom: move to different section
M.move = function(state)
  -- TODO: implement
  vim.notify("Move not yet implemented", vim.log.levels.INFO)
end

local function get_id(node)
  return node.id
end

-- Custom: reorder up (K)
M.move_up = function(state)
  local id = get_id(state.tree:get_node())
  if id and movement.move_up(vimoire_state, id) then
    M.refresh(state, id)
  end
end

-- Custom: reorder down (J)
M.move_down = function(state)
  local id = get_id(state.tree:get_node())
  if id and movement.move_down(vimoire_state, id) then
    M.refresh(state, id)
  end
end

return M
