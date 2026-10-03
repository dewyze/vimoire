local helpers = require("tests.helpers")

describe("stats", function()
  local stats
  local state

  before_each(function()
    helpers.reset()

    package.loaded["vimoire.stats"] = nil
    package.loaded["vimoire.state"] = nil
    package.loaded["vimoire.config"] = nil

    state = require("vimoire.state")
    stats = require("vimoire.stats")
  end)

  after_each(function()
    helpers.reset_state()
  end)

  describe("reading_time", function()
    it("returns hours and minutes for long books", function()
      state:load("tests/fixtures/standard")

      -- Mock calculate_book_words to return a known value
      local original = stats.calculate_book_words
      stats.calculate_book_words = function() return 30000 end

      local result = stats.reading_time()

      -- At 250 wpm: 30000 / 250 = 120 minutes = 2 hours
      assert.equals(2, result.hours)
      assert.equals(0, result.minutes)

      stats.calculate_book_words = original
    end)

    it("returns just minutes for short works", function()
      state:load("tests/fixtures/standard")

      local original = stats.calculate_book_words
      stats.calculate_book_words = function() return 2500 end

      local result = stats.reading_time()

      -- At 250 wpm: 2500 / 250 = 10 minutes
      assert.equals(0, result.hours)
      assert.equals(10, result.minutes)

      stats.calculate_book_words = original
    end)

    it("handles partial hours", function()
      state:load("tests/fixtures/standard")

      local original = stats.calculate_book_words
      stats.calculate_book_words = function() return 22500 end

      local result = stats.reading_time()

      -- At 250 wpm: 22500 / 250 = 90 minutes = 1h 30m
      assert.equals(1, result.hours)
      assert.equals(30, result.minutes)

      stats.calculate_book_words = original
    end)
  end)

  describe("daily_progress", function()
    local dir

    local function yesterday()
      local t = os.date("*t")
      return os.date("%Y-%m-%dT12:00:00", os.time({ year = t.year, month = t.month, day = t.day - 1, hour = 12 }))
    end

    before_each(function()
      dir = helpers.temp_copy("tests/fixtures/standard")
      local book = helpers.read_file(dir .. "/book.yml")
      helpers.write_file(dir .. "/book.yml", book .. "goals:\n  daily_words: 10\n")
      vim.fn.system("git -C " .. dir .. " init -q")
      vim.fn.system("git -C " .. dir .. " config user.email 'test@test.com'")
      vim.fn.system("git -C " .. dir .. " config user.name 'Test'")
      vim.system({ "git", "-C", dir, "add", "-A" }):wait()
      vim.system({ "git", "-C", dir, "commit", "-q", "-m", "setup" }, {
        env = { GIT_AUTHOR_DATE = yesterday(), GIT_COMMITTER_DATE = yesterday() },
      }):wait()
    end)

    after_each(function()
      helpers.cleanup(dir)
    end)

    it("counts today's net words from the book's history, not the session", function()
      local prose = dir .. "/entries/chap1a/prose.md"
      helpers.write_file(prose, helpers.read_file(prose) .. "\nfour more words here\n")
      state:load(dir)
      stats.init()

      local daily = stats.daily_progress()

      assert.same({ goal = 10, written = 4, percent = 40 }, daily)
    end)

    it("falls back to session words when the book is not a git repo", function()
      vim.fn.delete(dir .. "/.git", "rf")
      state:load(dir)
      stats.init()
      local prose = dir .. "/entries/chap1a/prose.md"
      helpers.write_file(prose, helpers.read_file(prose) .. "\ntwo more\n")

      assert.equals(2, stats.daily_progress().written)
    end)
  end)
end)
