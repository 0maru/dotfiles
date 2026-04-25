return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", function() require("oil").open() end, desc = "Open parent directory" },
  },
  opts = {
    keymaps = {
      ["<C-l>"] = false,
      ["gr"] = "actions.refresh",
    },
    view_options = {
      show_hidden = true,
    },
  },
}
