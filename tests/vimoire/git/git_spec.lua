local assert = require("luassert")
local state = require("vimoire.state")
local git = require("vimoire.git")
local json = require("vendor.dkjson")

describe("git", function()
  local dirs

  local function track(dir)
    table.insert(dirs, dir)
    return dir
  end

  local function make_git_book(opts)
    opts = opts or {}
    local dir = track(vim.fn.tempname())
    vim.fn.mkdir(dir, "p")
    if opts.repo ~= false then
      vim.fn.system("git -C " .. dir .. " init -q")
      vim.fn.system("git -C " .. dir .. " config user.email 'test@test.com'")
      vim.fn.system("git -C " .. dir .. " config user.name 'Test'")
    end

    local f = io.open(dir .. "/manuscript.json", "w")
    f:write(json.encode({ id = "test-ms", items = {} }))
    f:close()

    local Manuscript = require("vimoire.core.manuscript")
    state.manuscript = Manuscript.load(dir)
    return dir
  end

  local function log_lines(dir)
    local result = vim.system({ "git", "-C", dir, "log", "--format=%s" }, { text = true }):wait()
    return vim.split(result.stdout or "", "\n", { trimempty = true })
  end

  before_each(function()
    dirs = {}
    git.reset()
  end)

  after_each(function()
    state.manuscript = nil
    for _, dir in ipairs(dirs) do
      vim.fn.delete(dir, "rf")
    end
  end)

  describe("checkpoint", function()
    it("commits pending changes with a timestamped auto message", function()
      local dir = make_git_book()
      git.checkpoint()
      local log = log_lines(dir)
      assert.equals(1, #log)
      assert.matches("^auto: %d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d$", log[1])
    end)

    it("debounces a second commit inside the window", function()
      local dir = make_git_book()
      git.checkpoint()
      vim.fn.writefile({ "more words" }, dir .. "/chapter.md")
      git.checkpoint()
      assert.equals(1, #log_lines(dir))
    end)

    it("force bypasses the debounce (the on-quit backstop)", function()
      local dir = make_git_book()
      git.checkpoint()
      vim.fn.writefile({ "more words" }, dir .. "/chapter.md")
      git.checkpoint({ force = true })
      assert.equals(2, #log_lines(dir))
    end)

    it("does not consume the debounce window when the tree is clean", function()
      local dir = make_git_book()
      vim.fn.system("git -C " .. dir .. " add -A")
      vim.fn.system("git -C " .. dir .. " commit -q -m 'setup'")
      git.checkpoint()
      vim.fn.writefile({ "more words" }, dir .. "/chapter.md")
      git.checkpoint()
      assert.equals(2, #log_lines(dir))
    end)

    it("does nothing when the book root is not a git repo", function()
      local dir = make_git_book({ repo = false })
      git.checkpoint()
      assert.is_false(vim.fn.isdirectory(dir .. "/.git") == 1)
    end)
  end)
end)
