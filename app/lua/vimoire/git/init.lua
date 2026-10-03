-- Auto-commit for the book repo. Idle pauses (the same boundaries autosave
-- writes on) are the trigger: commits ride them through a debounce, with a
-- VimLeavePre backstop — vimoire is a persistent instance, quit is rare.
-- Writing stats derive per-day deltas by grouping commits on date, so
-- commit granularity beyond a few per session buys nothing; the debounce
-- keeps the log quiet. Commits capture disk state only — unsaved buffer
-- edits ride a later commit (autosave registers on the same events first).
-- :GitCommit stays for intentional milestone commits, which stand out
-- against the auto: timestamps.
--
-- Midnight closes the day: a minute timer watches the date, and when it
-- rolls over, buffers are saved and the day's work is committed dated
-- 23:59:59 of the day that ended. A poll rather than one long timer because
-- libuv timers run on a clock that stops while the Mac sleeps; a check that
-- runs late (laptop asleep at midnight) still dates to the ended day, since
-- nothing was written while asleep.
local M = {}

local config = require("vimoire.config")
local repo = require("vimoire.git.repo")
local state = require("vimoire.state")

local DEFAULT_AUTOCOMMIT_MINUTES = 30
local DAY_CHECK_MS = 60 * 1000

local last_commit = {}
local current_day = os.date("%Y-%m-%d")
local day_timer = nil

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

-- Close the day once the date at `now` has moved past it.
function M.check_day(now)
  local day = os.date("%Y-%m-%d", now)
  if day == current_day then
    return
  end
  local ended = current_day
  current_day = day

  vim.cmd("silent! wall")
  local root = state.manuscript.root
  if not repo.has_changes(root) then
    return
  end
  local closing = ended .. " 23:59:59"
  repo.commit(root, { message = "auto: " .. closing, date = ended .. "T23:59:59" })
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

-- Test hook: clear debounce state and start the day over.
function M.reset()
  last_commit = {}
  current_day = os.date("%Y-%m-%d")
end

local function watch_day()
  if day_timer then
    day_timer:stop()
    day_timer:close()
  end
  current_day = os.date("%Y-%m-%d")
  day_timer = vim.uv.new_timer()
  day_timer:start(DAY_CHECK_MS, DAY_CHECK_MS, vim.schedule_wrap(function()
    M.check_day(os.time())
  end))
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
  watch_day()
end

return M
