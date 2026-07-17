-- Raw git subprocess calls. No Vimoire state — takes root as an argument
-- everywhere.
local M = {}

local function run(root, args)
  local cmd = { "git", "-C", root }
  vim.list_extend(cmd, args)
  return vim.system(cmd, { text = true }):wait()
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
  local delta = 0
  for line in result.stdout:gmatch("[^\n]+") do
    local prefix = line:sub(1, 1)
    local header = line:sub(1, 3)
    if prefix == "+" and header ~= "+++" then
      for _ in line:sub(2):gmatch("%S+") do
        delta = delta + 1
      end
    elseif prefix == "-" and header ~= "---" then
      for _ in line:sub(2):gmatch("%S+") do
        delta = delta - 1
      end
    end
  end
  return delta
end

-- Stage everything (add -A picks up new chapters and deletions) and commit.
-- The message goes through a temp file (-F) so multiline messages survive.
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

  local result = run(root, { "commit", "-F", tmpfile })
  os.remove(tmpfile)

  if result.code ~= 0 then
    return false, "git commit failed: " .. (result.stderr or "")
  end

  return true, nil
end

return M
