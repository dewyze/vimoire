local M = {}

local function icon(hex)
  return vim.fn.nr2char(tonumber(hex, 16))
end

M.ICONS = {
  MANUSCRIPT = icon("0xf15d6"),
  SECTION = icon("0xe6ad"),
  CHAPTER = icon("0xf0bc2"),
  PAGE = icon("0xf249"),
  PLANNING = icon("0xf07c"),
  CHARACTERS = icon("0xf2b9"),
  SETTINGS = icon("0xf0984"),
  REFERENCE = icon("0xe678"),
  PLANNING_SECTION = icon("0xf07c"),
  PLANNING_ITEM = icon("0xf15c"),
}

M.HIGHLIGHTS = {
  MANUSCRIPT = "VimoireManuscript",
  SECTION = "VimoireSection",
  CHAPTER = "VimoireChapter",
  PAGE = "VimoirePage",
  PLANNING = "VimoirePlanning",
  PLANNING_SUBFOLDER = "VimoirePlanningSubfolder",
  PLANNING_ITEM = "VimoirePlanningItem",
}

return M
