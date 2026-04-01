return {
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Surround operations
  {
    "kylechui/nvim-surround",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Comment toggle
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Toggle comment" },
      { "gc", mode = { "n", "v" }, desc = "Comment" },
    },
    opts = {},
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },
}
