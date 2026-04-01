return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<Leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<Leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Grep" },
      { "<Leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<Leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<Leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<Leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<Leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<Leader>/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/", "%.lock" },
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
      },
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
}
