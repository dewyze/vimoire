-- Raw git subprocess calls. No Vimoire state — takes root as an argument
-- everywhere.
local M = {}

local function run(root, args, env)
  local cmd = { "git", "-C", root }
  vim.list_extend(cmd, args)
  return vim.system(cmd, { text = true, env = env }):wait()
end

local function count_words(text)
  local count = 0
  for _ in text:gmatch("%S+") do
    count = count + 1
  end
  return count
end

-- Words added and removed in --word-diff=porcelain output.
local function tally_word_diff(stdout)
  local added, removed = 0, 0
  for line in stdout:gmatch("[^\n]+") do
    local prefix = line:sub(1, 1)
    local header = line:sub(1, 3)
    if prefix == "+" and header ~= "+++" then
      added = added + count_words(line:sub(2))
    elseif prefix == "-" and header ~= "---" then
      removed = removed + count_words(line:sub(2))
    end
  end
  return added, removed
end

-- The empty tree's id, so "no start commit" diffs against nothing.
local function empty_tree(root)
  return vim.trim(run(root, { "hash-object", "-t", "tree", "/dev/null" }).stdout or "")
end

local function untracked_words(root, paths)
  local args = { "ls-files", "--others", "--exclude-standard", "-z", "--" }
  vim.list_extend(args, paths or {})
  local result = run(root, args)
  local words = 0
  for file in (result.stdout or ""):gmatch("[^%z]+") do
    local f = io.open(root .. "/" .. file, "r")
    if f then
      words = words + count_words(f:read("*a") or "")
      f:close()
    end
  end
  return words
end

function M.is_git_repo(root)
  local result = run(root, { "rev-parse", "--is-inside-work-tree" })
  return result.code == 0
end

function M.has_changes(root)
  local result = run(root, { "status", "--porcelain" })
  return result.code == 0 and result.stdout ~= nil and result.stdout ~= ""
end

function M.files_changed(root)
  local result = run(root, { "status", "--porcelain" })
  if result.code ~= 0 or not result.stdout then
    return 0
  end
  local count = 0
  for _ in result.stdout:gmatch("[^\n]+") do
    count = count + 1
  end
  return count
end

-- Net words added since HEAD, from the working tree (uncommitted changes).
function M.word_delta(root)
  local result = run(root, { "diff", "HEAD", "--word-diff=porcelain" })
  if result.code ~= 0 or not result.stdout then
    return 0
  end
  local added, removed = tally_word_diff(result.stdout)
  return added - removed
end

-- Words added and removed between two points. `from` defaults to the empty
-- tree; `to` defaults to the working tree, untracked files included.
-- `paths` limits the count to matching pathspecs.
function M.word_changes(root, opts)
  local args = { "diff", opts.from or empty_tree(root) }
  if opts.to then
    table.insert(args, opts.to)
  end
  vim.list_extend(args, { "--word-diff=porcelain", "--" })
  vim.list_extend(args, opts.paths or {})

  local result = run(root, args)
  local added, removed = 0, 0
  if result.code == 0 and result.stdout then
    added, removed = tally_word_diff(result.stdout)
  end
  if not opts.to then
    added = added + untracked_words(root, opts.paths)
  end
  return { added = added, removed = removed }
end

-- Commits newest first, each with the local calendar day of its author date.
function M.log(root)
  local result = run(root, { "log", "--format=%H %ad", "--date=format-local:%Y-%m-%d" })
  local commits = {}
  if result.code ~= 0 or not result.stdout then
    return commits
  end
  for sha, day in result.stdout:gmatch("(%x+) (%S+)") do
    table.insert(commits, { sha = sha, day = day })
  end
  return commits
end

-- Stage everything (add -A picks up new chapters and deletions) and commit.
-- The message goes through a temp file (-F) so multiline messages survive.
-- An optional `date` (local "YYYY-MM-DDTHH:MM:SS") backdates the commit.
function M.commit(root, opts)
  local message = (opts.message or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if message == "" then
    return false, "commit message is empty"
  end

  local add_result = run(root, { "add", "-A" })
  if add_result.code ~= 0 then
    return false, "git add failed: " .. (add_result.stderr or "")
  end

  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, "w")
  if not f then
    return false, "failed to create temp file for commit message"
  end
  f:write(message)
  f:close()

  local env = opts.date and { GIT_AUTHOR_DATE = opts.date, GIT_COMMITTER_DATE = opts.date } or nil
  local result = run(root, { "commit", "-F", tmpfile }, env)
  os.remove(tmpfile)

  if result.code ~= 0 then
    return false, "git commit failed: " .. (result.stderr or "")
  end

  return true, nil
end

return M
