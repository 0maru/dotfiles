return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<Leader>cf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
    },
    opts = {
      formatters_by_ft = {
        go = { "gofumpt", "goimports" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },
}
