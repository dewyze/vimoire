-- Auto-commit for the book repo. Idle pauses (the same boundaries autosave
-- writes on) are the trigger: commits ride them through a debounce, with a
-- VimLeavePre backstop — vimoire is a persistent instance, quit is rare.
-- Writing stats derive per-day deltas by grouping commits on date, so
-- commit granularity beyond a few per session buys nothing; the debounce
-- keeps the log quiet. Commits capture disk state only — unsaved buffer
-- edits ride a later commit (autosave registers on the same events first).
-- :GitCommit stays for intentional milestone commits, which stand out
-- against the auto: timestamps.
local M = {}

local config = require("vimoire.config")
local repo = require("vimoire.git.repo")
local state = require("vimoire.state")

local DEFAULT_AUTOCOMMIT_MINUTES = 30

local last_commit = {}

local function debounce_seconds()
  local minutes = tonumber(config.get("git.autocommit_minutes")) or DEFAULT_AUTOCOMMIT_MINUTES
  return minutes * 60
end

-- Commit whatever is pending, debounced per book root on actual commits —
-- a clean checkpoint doesn't consume the window, so the next dirty pause
-- commits immediately.
function M.checkpoint(opts)
  opts = opts or {}
  local root = state.manuscript.root
  local now = os.time()
  if not opts.force and now - (last_commit[root] or 0) < debounce_seconds() then
    return
  end
  if not repo.has_changes(root) then
    return
  end
  if repo.commit(root, { message = "auto: " .. os.date("%Y-%m-%d %H:%M:%S") }) then
    last_commit[root] = now
  end
end

-- Manual milestone commit via the float editor.
function M.commit()
  local root = state.manuscript.root
  if not repo.is_git_repo(root) then
    vim.notify("Not a git repository", vim.log.levels.WARN)
    return
  end
  require("vimoire.git.commit_editor").open(root)
end

-- Test hook: clear debounce state.
function M.reset()
  last_commit = {}
end

function M.setup()
  if not config.get("git.enabled") then
    return
  end
  if not repo.is_git_repo(state.manuscript.root) then
    return
  end

  local group = vim.api.nvim_create_augroup("VimoireGit", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave", "BufLeave" }, {
    group = group,
    callback = function()
      M.checkpoint()
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      M.checkpoint({ force = true })
    end,
  })
end

return M
