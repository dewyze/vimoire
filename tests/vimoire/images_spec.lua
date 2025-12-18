local assert = require("luassert")
local Path = require("plenary.path")
local helpers = require("tests.helpers")
local images = require("vimoire.images")

describe("images", function()
  local temp_dir

  before_each(function()
    temp_dir = helpers.temp_dir()
  end)

  after_each(function()
    helpers.cleanup(temp_dir)
  end)

  describe("dir", function()
    it("returns assets/images path", function()
      local result = images.dir(temp_dir)
      assert.equals(temp_dir .. "/assets/images", result)
    end)
  end)

  describe("list", function()
    it("returns empty array when directory missing", function()
      local result = images.list(temp_dir)
      assert.same({}, result)
    end)

    it("returns empty array when directory is empty", function()
      Path:new(temp_dir, "assets", "images"):mkdir({ parents = true })

      local result = images.list(temp_dir)
      assert.same({}, result)
    end)

    it("returns image filenames", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      Path:new(img_dir, "cat.png"):write("fake png", "w")
      Path:new(img_dir, "dog.jpg"):write("fake jpg", "w")

      local result = images.list(temp_dir)

      assert.equals(2, #result)
      assert.is_true(vim.tbl_contains(result, "cat.png"))
      assert.is_true(vim.tbl_contains(result, "dog.jpg"))
    end)

    it("filters to image extensions only", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      Path:new(img_dir, "cat.png"):write("fake png", "w")
      Path:new(img_dir, ".gitkeep"):write("", "w")
      Path:new(img_dir, "readme.txt"):write("notes", "w")

      local result = images.list(temp_dir)

      assert.equals(1, #result)
      assert.equals("cat.png", result[1])
    end)

    it("includes all supported image extensions", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      Path:new(img_dir, "a.png"):write("", "w")
      Path:new(img_dir, "b.jpg"):write("", "w")
      Path:new(img_dir, "c.jpeg"):write("", "w")
      Path:new(img_dir, "d.gif"):write("", "w")
      Path:new(img_dir, "e.webp"):write("", "w")
      Path:new(img_dir, "f.svg"):write("", "w")

      local result = images.list(temp_dir)

      assert.equals(6, #result)
    end)
  end)

  describe("exists", function()
    it("returns false when directory missing", function()
      local result = images.exists(temp_dir, "cat.png")
      assert.is_false(result)
    end)

    it("returns false when image not found", function()
      Path:new(temp_dir, "assets", "images"):mkdir({ parents = true })

      local result = images.exists(temp_dir, "cat.png")
      assert.is_false(result)
    end)

    it("returns true when image exists", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      Path:new(img_dir, "cat.png"):write("fake png", "w")

      local result = images.exists(temp_dir, "cat.png")
      assert.is_true(result)
    end)
  end)

  describe("copy", function()
    local src_file

    before_each(function()
      -- Create a source image outside assets
      src_file = temp_dir .. "/external/photo.png"
      Path:new(temp_dir, "external"):mkdir({ parents = true })
      Path:new(src_file):write("png content", "w")
    end)

    it("copies file to assets/images", function()
      Path:new(temp_dir, "assets", "images"):mkdir({ parents = true })

      local dest = images.copy(temp_dir, src_file)

      assert.equals(temp_dir .. "/assets/images/photo.png", dest)
      assert.is_true(Path:new(dest):exists())
      assert.equals("png content", Path:new(dest):read())
    end)

    it("creates assets/images if missing", function()
      local dest = images.copy(temp_dir, src_file)

      assert.is_true(Path:new(dest):exists())
    end)

    it("preserves original filename", function()
      local dest = images.copy(temp_dir, src_file)

      assert.matches("photo%.png$", dest)
    end)

    it("returns nil if source does not exist", function()
      local dest = images.copy(temp_dir, temp_dir .. "/nope.png")
      assert.is_nil(dest)
    end)
  end)

  describe("delete", function()
    it("removes image from assets/images", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      local img_path = img_dir .. "/cat.png"
      Path:new(img_path):write("fake", "w")

      local result = images.delete(temp_dir, "cat.png")

      assert.is_true(result)
      assert.is_false(Path:new(img_path):exists())
    end)

    it("returns false when image not found", function()
      Path:new(temp_dir, "assets", "images"):mkdir({ parents = true })

      local result = images.delete(temp_dir, "nope.png")
      assert.is_false(result)
    end)

    it("returns false when directory missing", function()
      local result = images.delete(temp_dir, "nope.png")
      assert.is_false(result)
    end)
  end)

  describe("full_path", function()
    it("returns full path to image", function()
      local result = images.full_path(temp_dir, "cat.png")
      assert.equals(temp_dir .. "/assets/images/cat.png", result)
    end)
  end)

  describe("rename", function()
    it("renames image file", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      Path:new(img_dir, "old.png"):write("fake", "w")

      local ok = images.rename(temp_dir, "old.png", "new.png")

      assert.is_true(ok)
      assert.is_false(Path:new(img_dir, "old.png"):exists())
      assert.is_true(Path:new(img_dir, "new.png"):exists())
    end)

    it("returns false when source not found", function()
      Path:new(temp_dir, "assets", "images"):mkdir({ parents = true })

      local ok, err = images.rename(temp_dir, "nope.png", "new.png")

      assert.is_false(ok)
      assert.equals("File not found", err)
    end)

    it("returns false when destination exists", function()
      local img_dir = temp_dir .. "/assets/images"
      Path:new(img_dir):mkdir({ parents = true })
      Path:new(img_dir, "old.png"):write("fake", "w")
      Path:new(img_dir, "existing.png"):write("fake", "w")

      local ok, err = images.rename(temp_dir, "old.png", "existing.png")

      assert.is_false(ok)
      assert.equals("File already exists", err)
    end)
  end)
end)
