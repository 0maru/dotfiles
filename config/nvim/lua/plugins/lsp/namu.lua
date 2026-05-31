return {
  "bassamsdata/namu.nvim",
  opts = {
    global = {},
    namu_symbols = {
      options = {},
    },
  },
  keys = {
    { "<leader>ls", "<Cmd>Namu symbols<CR>", desc = "Jump to LSP symbol" },
    { "<leader>lw", "<Cmd>Namu workspace<CR>", desc = "LSP Symbols - Workspace" },
  },
}
