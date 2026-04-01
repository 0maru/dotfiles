return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        gitsigns = true,
        indent_blankline = { enabled = true },
        mason = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
        harpoon = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
