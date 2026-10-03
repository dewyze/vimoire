local assert = require("luassert")
local History = require("vimoire.git.history")

describe("git.history", function()
  local dirs

  local function make_book()
    local dir = vim.fn.tempname()
    table.insert(dirs, dir)
    vim.fn.mkdir(dir, "p")
    vim.fn.system("git -C " .. dir .. " init -q")
    vim.fn.system("git -C " .. dir .. " config user.email 'test@test.com'")
    vim.fn.system("git -C " .. dir .. " config user.name 'Test'")
    return dir
  end

  local function write_prose(dir, id, content)
    vim.fn.mkdir(dir .. "/entries/" .. id, "p")
    vim.fn.writefile(vim.split(content, "\n"), dir .. "/entries/" .. id .. "/prose.md")
  end

  -- Local "YYYY-MM-DD" for `offset` days from today.
  local function day(offset)
    local t = os.date("*t")
    return os.date("%Y-%m-%d", os.time({ year = t.year, month = t.month, day = t.day + offset, hour = 12 }))
  end

  local function commit_on(dir, date_day, time)
    local date = date_day .. "T" .. (time or "12:00:00")
    vim.system({ "git", "-C", dir, "add", "-A" }):wait()
    vim.system({ "git", "-C", dir, "commit", "-q", "-m", "auto" }, {
      env = { GIT_AUTHOR_DATE = date, GIT_COMMITTER_DATE = date },
    }):wait()
  end

  before_each(function()
    dirs = {}
  end)

  after_each(function()
    for _, dir in ipairs(dirs) do
      vim.fn.delete(dir, "rf")
    end
  end)

  describe("days", function()
    it("returns the requested number of calendar days, newest first", function()
      local dir = make_book()
      local days = History.new(dir):days(3)
      assert.same({ day(0), day(-1), day(-2) }, vim.tbl_map(function(d) return d.day end, days))
    end)

    it("measures each day against the end of the day before", function()
      local dir = make_book()
      write_prose(dir, "ch1", "one two three")
      commit_on(dir, day(-3))
      write_prose(dir, "ch1", "one two three four five")
      commit_on(dir, day(-2), "09:00:00")
      write_prose(dir, "ch1", "one two three four five six")
      commit_on(dir, day(-2), "21:00:00")
      write_prose(dir, "ch1", "one six seven")
      commit_on(dir, day(-1))

      local days = History.new(dir):days(3)

      assert.same({ 3, 0 }, { days[3].added, days[3].removed })
      assert.same({ 1, 4 }, { days[2].added, days[2].removed })
      assert.equals(-3, days[2]:net())
    end)

    it("reports zero for days without commits", function()
      local dir = make_book()
      write_prose(dir, "ch1", "one two")
      commit_on(dir, day(-3))
      write_prose(dir, "ch1", "one two three")
      commit_on(dir, day(-1))

      local days = History.new(dir):days(3)

      assert.same({ 0, 0 }, { days[3].added, days[3].removed })
      assert.same({ 1, 0 }, { days[2].added, days[2].removed })
    end)

    it("includes uncommitted and untracked prose in today", function()
      local dir = make_book()
      write_prose(dir, "ch1", "one two")
      commit_on(dir, day(-1))
      write_prose(dir, "ch1", "one two three")
      write_prose(dir, "ch2", "a whole new chapter")

      local today = History.new(dir):days(1)[1]

      assert.same({ 5, 0 }, { today.added, today.removed })
    end)

    it("counts only prose", function()
      local dir = make_book()
      write_prose(dir, "ch1", "one")
      commit_on(dir, day(-1))
      vim.fn.mkdir(dir .. "/planning", "p")
      vim.fn.writefile({ "outline words that do not count" }, dir .. "/planning/outline.md")
      vim.fn.writefile({ "notes do not count" }, dir .. "/entries/ch1/notes.md")

      local today = History.new(dir):days(1)[1]

      assert.equals(0, today.added)
    end)
  end)

  describe("today", function()
    it("is the current day's writing", function()
      local dir = make_book()
      write_prose(dir, "ch1", "one two")
      commit_on(dir, day(-1))
      write_prose(dir, "ch1", "one")

      local today = History.new(dir):today()

      assert.equals(day(0), today.day)
      assert.equals(-1, today:net())
    end)
  end)
end)
