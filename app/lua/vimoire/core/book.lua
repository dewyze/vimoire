local Book = {}
local Path = require("plenary.path")
local yaml = require("vendor.tinyyaml")

Book.KIND = "book"
Book.ID = "book"

function Book.load(root_path)
  local book_file = Path:new(root_path, "book.yml")

  if not book_file:exists() then
    return nil, "book.yml not found at " .. root_path
  end

  local content, err = book_file:read()
  if not content then
    return nil, "Failed to read book.yml: " .. err
  end

  local ok, data = pcall(yaml.parse, content)
  if not ok then
    return nil, "Failed to parse book.yml: " .. data
  end

  return Book.new(data, root_path)
end

function Book.new(data, root_path)
  local self = setmetatable({}, { __index = Book })
  self.id = Book.ID
  self.kind = Book.KIND
  self.immutable = true
  self.title = data.title or "Untitled"
  self.author = data.author or ""
  self.description = data.description or ""
  self.language = data.language or "en"
  self.copyright = data.copyright
  self.publisher = data.publisher
  self.isbn = data.isbn
  self.cover = data.cover
  self.root = root_path
  self.goals = data.goals or {}
  return self
end

function Book:action()
  return false
end

function Book:path()
  return Path:new(self.root, "book.yml"):absolute()
end

function Book:text_path()
  return self:path()
end

function Book:display_name()
  return "Book Info"
end

function Book:category()       return "default" end
function Book:comments_path()  return nil end
function Book:notes_path()     return nil end
function Book:render_extras()  return {} end

return Book
