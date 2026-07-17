local assert = require("luassert")
local repo = require("vimoire.git.repo")

describe("git.repo", function()
  local dirs

  local function track(dir)
    table.insert(dirs, dir)
    return dir
  end

  local function make_temp_dir()
    local dir = track(vim.fn.tempname())
    vim.fn.mkdir(dir, "p")
    return dir
  end

  local function make_temp_repo()
    local dir = make_temp_dir()
    vim.fn.system("git -C " .. dir .. " init -q")
    vim.fn.system("git -C " .. dir .. " config user.email 'test@test.com'")
    vim.fn.system("git -C " .. dir .. " config user.name 'Test'")
    return dir
  end

  local function write_file(dir, name, content)
    local f = io.open(dir .. "/" .. name, "w")
    f:write(content)
    f:close()
  end

  local function plain_commit(dir)
    vim.fn.system("git -C " .. dir .. " add -A")
    vim.fn.system("git -C " .. dir .. " commit -q -m 'setup'")
  end

  before_each(function()
    dirs = {}
  end)

  after_each(function()
    for _, dir in ipairs(dirs) do
      vim.fn.delete(dir, "rf")
    end
  end)

  describe("is_git_repo", function()
    it("returns true for a git repo", function()
      assert.is_true(repo.is_git_repo(make_temp_repo()))
    end)

    it("returns false for a plain directory", function()
      assert.is_false(repo.is_git_repo(make_temp_dir()))
    end)
  end)

  describe("has_changes", function()
    it("returns true for untracked files", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      assert.is_true(repo.has_changes(dir))
    end)

    it("returns true for uncommitted modifications", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      plain_commit(dir)
      write_file(dir, "test.md", "modified")
      assert.is_true(repo.has_changes(dir))
    end)

    it("returns false when the tree is clean", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      plain_commit(dir)
      assert.is_false(repo.has_changes(dir))
    end)

    it("returns false for a plain directory", function()
      assert.is_false(repo.has_changes(make_temp_dir()))
    end)
  end)

  describe("files_changed", function()
    it("counts pending files", function()
      local dir = make_temp_repo()
      write_file(dir, "one.md", "a")
      write_file(dir, "two.md", "b")
      assert.equals(2, repo.files_changed(dir))
    end)

    it("returns zero when clean", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      plain_commit(dir)
      assert.equals(0, repo.files_changed(dir))
    end)
  end)

  describe("word_delta", function()
    it("returns net words added since HEAD", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "one two three\n")
      plain_commit(dir)
      write_file(dir, "test.md", "one two three four five\n")
      assert.equals(2, repo.word_delta(dir))
    end)

    it("returns a negative delta when words are removed", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "one two three four five\n")
      plain_commit(dir)
      write_file(dir, "test.md", "one\n")
      assert.equals(-4, repo.word_delta(dir))
    end)
  end)

  describe("commit", function()
    local function log_lines(dir)
      local result = vim.system({ "git", "-C", dir, "log", "--format=%s" }, { text = true }):wait()
      return vim.split(result.stdout or "", "\n", { trimempty = true })
    end

    it("stages everything and commits with the given message", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      local ok, err = repo.commit(dir, { message = "auto: checkpoint" })
      assert.is_true(ok)
      assert.is_nil(err)
      assert.same({ "auto: checkpoint" }, log_lines(dir))
      assert.is_false(repo.has_changes(dir))
    end)

    it("preserves multiline messages", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      repo.commit(dir, { message = "finished ch. 8\n\nrough draft done" })
      local result = vim.system({ "git", "-C", dir, "log", "--format=%B" }, { text = true }):wait()
      assert.matches("finished ch%. 8\n\nrough draft done", result.stdout)
    end)

    it("fails with an error for an empty message", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      local ok, err = repo.commit(dir, { message = "" })
      assert.is_false(ok)
      assert.matches("empty", err)
    end)

    it("fails when there is nothing to commit", function()
      local dir = make_temp_repo()
      write_file(dir, "test.md", "hello")
      plain_commit(dir)
      local ok = repo.commit(dir, { message = "nothing here" })
      assert.is_false(ok)
    end)
  end)
end)
