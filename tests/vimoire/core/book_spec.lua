local assert = require("luassert")

describe("Book", function()
  local Book = require("vimoire.core.book")
  local example_path = "tests/fixtures/standard"

  it("loads a book from disk", function()
    local book = Book.load(example_path)

    assert.is_not_nil(book)
    assert.equals("The Unreliable Memoirs of Gerald the Sentient Toaster", book.title)
    assert.equals("Author Name", book.author)
    assert.equals("en", book.language)
  end)

  it("returns error for missing book.yml", function()
    local book, err = Book.load("tests/fixtures/nonexistent")

    assert.is_nil(book)
    assert.matches("book.yml not found", err)
  end)

  it("provides path to book.yml", function()
    local book = Book.load(example_path)

    assert.matches("tests/fixtures/standard/book.yml$", book:path())
  end)

  it("defaults missing fields", function()
    local book = Book.new({}, example_path)

    assert.equals("Untitled", book.title)
    assert.equals("", book.author)
    assert.equals("", book.description)
    assert.equals("en", book.language)
  end)
end)
