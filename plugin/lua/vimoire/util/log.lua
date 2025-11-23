local log = {}

local levels = {
  debug = 0,
  info = 1,
  warn = 2,
  error = 3,
}

local level_names = {
  [0] = "DEBUG",
  [1] = "INFO",
  [2] = "WARN",
  [3] = "ERROR",
}

-- Default to info level; users can override
log.level = levels.info

function log.debug(msg)
  if log.level <= levels.debug then
    vim.notify("[vimoire] " .. msg, vim.log.levels.DEBUG)
  end
end

function log.info(msg)
  if log.level <= levels.info then
    vim.notify("[vimoire] " .. msg, vim.log.levels.INFO)
  end
end

function log.warn(msg)
  if log.level <= levels.warn then
    vim.notify("[vimoire] " .. msg, vim.log.levels.WARN)
  end
end

function log.error(msg)
  if log.level <= levels.error then
    vim.notify("[vimoire] " .. msg, vim.log.levels.ERROR)
  end
end

function log.set_level(level)
  if type(level) == "string" then
    log.level = levels[level] or levels.info
  else
    log.level = level
  end
end

return log
