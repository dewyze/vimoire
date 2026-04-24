local ActionItem = {}

function ActionItem.new(id, name, action_fn)
  local self = setmetatable({}, { __index = ActionItem })
  self.id = id
  self.name = name
  self.kind = "action"
  self.immutable = true
  self._action_fn = action_fn
  return self
end

function ActionItem:action()
  self._action_fn()
  return true
end

function ActionItem:display_name()
  return self.name
end

function ActionItem:text_path()
  return nil
end

function ActionItem:category()
  return "default"
end

return ActionItem
