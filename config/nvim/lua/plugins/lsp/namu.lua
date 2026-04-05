return {
  "bassamsdata/namu.nvim",
  opts = {
    global = {},
    namu_symbols = {
      options = {},
    },
  },
  keys = {
    { "<leader>ss", "<Cmd>Namu symbols<CR>", desc = "Jump to LSP symbol" },
    { "<leader>sw", "<Cmd>Namu workspace<CR>", desc = "LSP Symbols - Workspace" },
  },
}
