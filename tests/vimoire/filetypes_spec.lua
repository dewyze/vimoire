local filetypes = require("vimoire.filetypes")

describe("filetypes", function()
  describe("setup", function()
    it("registers filetypes and treesitter without error", function()
      assert.has_no.errors(function()
        filetypes.setup()
      end)
    end)
  end)

  describe("vimoire_prose settings", function()
    before_each(function()
      filetypes.setup()
    end)

    it("sets prose display options when filetype is set", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo[buf].filetype = "vimoire_prose"

      assert.is_true(vim.wo.wrap)
      assert.is_true(vim.wo.linebreak)
      assert.is_false(vim.wo.breakindent)
      assert.equals(0, vim.bo.textwidth)
      assert.is_true(vim.wo.cursorline)
    end)

    it("maps j/k to gj/gk for soft-wrap navigation", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.bo[buf].filetype = "vimoire_prose"

      local j_map = vim.fn.maparg("j", "n", false, true)
      local k_map = vim.fn.maparg("k", "n", false, true)

      assert.equals("gj", j_map.rhs)
      assert.equals("gk", k_map.rhs)
      assert.equals(1, j_map.buffer, "j should be buffer-local")
      assert.equals(1, k_map.buffer, "k should be buffer-local")
    end)
  end)
end)
