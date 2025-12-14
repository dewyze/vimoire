local Path = require("plenary.path")
local id = require("vimoire.util.id")

local M = {}

local function get_template_path(template_name)
  local results = vim.api.nvim_get_runtime_file("templates/" .. template_name, false)
  return results[1]
end

local function copy_template(template_name, dest_dir)
  local src = get_template_path(template_name)
  if src then
    vim.fn.system({ "cp", "-r", src .. "/.", dest_dir })
  end
end

function M.create(project_dir, title)

  -- Generate IDs
  local ids = {}
  local manuscript_id = id.generate(ids)
  table.insert(ids, manuscript_id)
  local dedication_id = id.generate(ids)
  table.insert(ids, dedication_id)
  local chapter_id = id.generate(ids)
  table.insert(ids, chapter_id)
  local protagonist_id = id.generate(ids)
  table.insert(ids, protagonist_id)
  local research_id = id.generate(ids)

  -- Create directory structure
  Path:new(project_dir):mkdir({ parents = true })
  Path:new(project_dir, "entries"):mkdir()
  Path:new(project_dir, "planning", "characters"):mkdir({ parents = true })
  Path:new(project_dir, "planning", "settings"):mkdir({ parents = true })
  Path:new(project_dir, "planning", "reference"):mkdir({ parents = true })
  Path:new(project_dir, "spell"):mkdir()

  -- Copy starter entries
  Path:new(project_dir, "entries", dedication_id):mkdir()
  copy_template("entries/dedication", project_dir .. "/entries/" .. dedication_id)

  Path:new(project_dir, "entries", chapter_id):mkdir()
  copy_template("entries/chapter1", project_dir .. "/entries/" .. chapter_id)

  -- Copy starter planning docs
  Path:new(project_dir, "planning", protagonist_id):mkdir()
  copy_template("planning/protagonist", project_dir .. "/planning/" .. protagonist_id)

  Path:new(project_dir, "planning", research_id):mkdir()
  copy_template("planning/research", project_dir .. "/planning/" .. research_id)

  -- Create book.yml
  local book_yml = string.format([[title: "%s"
author: "Author Name"
description: ""
language: en
]], title:gsub('"', '\\"'))
  Path:new(project_dir, "book.yml"):write(book_yml, "w")

  -- Create manuscript.json
  local manuscript = {
    id = manuscript_id,
    items = {
      { id = dedication_id, kind = "page", name = "Dedication" },
      { id = chapter_id, kind = "chapter", name = "Chapter 1" },
    },
    characters = {
      { id = protagonist_id, name = "Protagonist" },
    },
    settings = {},
    reference = {
      { id = research_id, name = "Research Notes" },
    },
  }

  local json = vim.json.encode(manuscript)
  Path:new(project_dir, "manuscript.json"):write(json, "w")

  return project_dir
end

return M
