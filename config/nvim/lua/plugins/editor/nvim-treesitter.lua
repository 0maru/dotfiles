return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local parsers = {
        "typescript", "javascript", "tsx", "vue",
        "html", "css", "json", "jsonc", "yaml", "toml", "xml",
        "markdown", "markdown_inline", "jsdoc",
        "dockerfile", "bash", "diff", "regex",
        "c", "lua", "luadoc", "luap", "vim", "vimdoc", "printf",
        "python", "rust", "go", "gomod", "gosum", "htmldjango",
      }

      local ts = require("nvim-treesitter")
      local installed = ts.get_installed()
      local to_install = {}
      for _, parser in ipairs(parsers) do
        if not vim.list_contains(installed, parser) then
          table.insert(to_install, parser)
        end
      end
      if #to_install > 0 then
        ts.install(to_install)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.bo[buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          local ok = pcall(vim.treesitter.language.inspect, lang)
          if ok then
            vim.treesitter.start(buf, lang)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ts_textobjects = require("nvim-treesitter-textobjects")
      ts_textobjects.setup({ select = { lookahead = true } })

      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")

      -- move
      local move_maps = {
        { "]f", move.goto_next_start, "@function.outer" },
        { "]c", move.goto_next_start, "@class.outer" },
        { "]a", move.goto_next_start, "@parameter.inner" },
        { "]F", move.goto_next_end, "@function.outer" },
        { "]C", move.goto_next_end, "@class.outer" },
        { "]A", move.goto_next_end, "@parameter.inner" },
        { "[f", move.goto_previous_start, "@function.outer" },
        { "[c", move.goto_previous_start, "@class.outer" },
        { "[a", move.goto_previous_start, "@parameter.inner" },
        { "[F", move.goto_previous_end, "@function.outer" },
        { "[C", move.goto_previous_end, "@class.outer" },
        { "[A", move.goto_previous_end, "@parameter.inner" },
      }
      for _, m in ipairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function() m[2](m[3]) end)
      end

      -- select
      local select_maps = {
        { "af", "@function.outer" },
        { "if", "@function.inner" },
        { "ac", "@class.outer" },
        { "ic", "@class.inner" },
        { "aa", "@parameter.outer" },
        { "ia", "@parameter.inner" },
      }
      for _, s in ipairs(select_maps) do
        vim.keymap.set({ "x", "o" }, s[1], function() select.select_textobject(s[2]) end)
      end
    end,
  },
}
