local helpers = require("tests.helpers")

describe("stats_window", function()
  local stats_window
  local state
  local dir
  local win

  local function days_ago(n)
    local t = os.date("*t")
    return os.time({ year = t.year, month = t.month, day = t.day - n, hour = 12 })
  end

  before_each(function()
    helpers.reset()
    package.loaded["vimoire.state"] = nil
    package.loaded["vimoire.stats"] = nil
    package.loaded["vimoire.ui.stats_window"] = nil
    state = require("vimoire.state")
    stats_window = require("vimoire.ui.stats_window")

    dir = helpers.temp_copy("tests/fixtures/standard")
    vim.fn.system("git -C " .. dir .. " init -q")
    vim.fn.system("git -C " .. dir .. " config user.email 'test@test.com'")
    vim.fn.system("git -C " .. dir .. " config user.name 'Test'")
    local date = os.date("%Y-%m-%dT12:00:00", days_ago(1))
    vim.system({ "git", "-C", dir, "add", "-A" }):wait()
    vim.system({ "git", "-C", dir, "commit", "-q", "-m", "setup" }, {
      env = { GIT_AUTHOR_DATE = date, GIT_COMMITTER_DATE = date },
    }):wait()
  end)

  after_each(function()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    helpers.cleanup(dir)
    helpers.reset_state()
  end)

  it("lists recent days with words added, removed, and net", function()
    local prose = dir .. "/entries/chap1a/prose.md"
    helpers.write_file(prose, helpers.read_file(prose) .. "\nfour more words here\n")
    state:load(dir)
    require("vimoire.stats").init()

    local buf
    buf, win = stats_window.show()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local today = os.date("%a %b %d")
    local row = vim.tbl_filter(function(line) return line:find(today, 1, true) end, lines)[1]
    assert.is_not_nil(row)
    assert.same({ "+4", "0", "+4" }, vim.split(vim.trim(row:sub(#today + 3)), "%s+"))

    local yesterday = os.date("%a %b %d", days_ago(1))
    assert.is_truthy(vim.tbl_filter(function(line) return line:find(yesterday, 1, true) end, lines)[1])
  end)
end)
