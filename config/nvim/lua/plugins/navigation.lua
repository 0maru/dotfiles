return {
  -- Harpoon: quick file jumping
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<Leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<Leader>h", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<Leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<Leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<Leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<Leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- Smart splits: seamless WezTerm ↔ Neovim pane navigation
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to lower split" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to upper split" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
      { "<Leader>sr", function() require("smart-splits").start_resize_mode() end, desc = "Resize mode" },
    },
  },

  -- TODO/FIXME highlights
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<Leader>ft", "<Cmd>TodoTelescope<CR>", desc = "Find TODOs" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
    },
    opts = {},
  },
}
