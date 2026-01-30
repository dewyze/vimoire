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
end)
