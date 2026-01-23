vim.api.nvim_create_user_command("Snippets", function()
  local state = require("vimoire.state")
  local snippets = require("vimoire.snippets")
  local snippet_editor = require("vimoire.snippet_editor")
  local Snacks = require("snacks")

  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local root = state.manuscript.root
  local snippet_list = snippets.load(root)
  if #snippet_list == 0 then
    vim.notify("No snippets", vim.log.levels.INFO)
    return
  end

  local function truncate(text, max_len)
    local first_line = text:match("^([^\n]*)")
    if #first_line > max_len then
      return first_line:sub(1, max_len - 3) .. "..."
    end
    return first_line
  end

  local function build_preview(snippet)
    local parts = { snippet.text }
    if snippet.description then
      table.insert(parts, "\n\n------\n\n" .. snippet.description)
    end
    return table.concat(parts)
  end

  local picker_items = {}
  for _, snippet in ipairs(snippet_list) do
    table.insert(picker_items, {
      text = truncate(snippet.text, 50),
      snippet = snippet,
      preview_text = build_preview(snippet),
    })
  end

  Snacks.picker({
    title = "Snippets",
    items = picker_items,
    preview = function(ctx)
      if ctx.item and ctx.item.preview_text then
        local lines = vim.split(ctx.item.preview_text, "\n")
        vim.bo[ctx.buf].modifiable = true
        vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)
        vim.bo[ctx.buf].modifiable = false
        vim.bo[ctx.buf].filetype = "markdown"
        vim.wo[ctx.win].wrap = true
        vim.wo[ctx.win].linebreak = true
        vim.wo[ctx.win].list = false
      end
      return true
    end,
    format = function(item)
      return { { item.text, "Normal" } }
    end,
    actions = {
      edit_snippet = function(picker)
        local sel = picker:current()
        if sel and sel.snippet then
          picker:close()
          snippet_editor.open({
            root = root,
            snippet_id = sel.snippet.id,
          })
        end
      end,
      delete_snippet = function(picker)
        local sel = picker:current()
        if sel and sel.snippet then
          snippets.remove(root, sel.snippet.id)
          vim.notify("Snippet deleted", vim.log.levels.INFO)
          picker:close()
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-e>"] = { "edit_snippet", mode = { "n", "i" }, desc = "Edit snippet" },
          ["<C-d>"] = { "delete_snippet", mode = { "n", "i" }, desc = "Delete snippet" },
        },
      },
    },
    confirm = function(picker, selected)
      if selected and selected.snippet then
        local text = selected.snippet.text
        vim.fn.setreg('"', text)
        snippets.remove(root, selected.snippet.id)
        picker:close()
        local lines = vim.split(text, "\n")
        vim.api.nvim_put(lines, "c", true, true)
      end
    end,
  })
end, { desc = "Browse snippets" })

vim.api.nvim_create_user_command("SnippetExtract", function()
  local state = require("vimoire.state")
  local snippet_editor = require("vimoire.snippet_editor")

  if not state.manuscript then
    vim.notify("No manuscript loaded", vim.log.levels.WARN)
    return
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(
    0,
    start_pos[2] - 1,
    start_pos[3] - 1,
    end_pos[2] - 1,
    end_pos[3],
    {}
  )
  local text = table.concat(lines, "\n")

  if text == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  vim.cmd("normal! gvd")
  snippet_editor.open({
    root = state.manuscript.root,
    text = text,
  })
end, { range = true, desc = "Extract selection as snippet" })
