return {
  -- Mason: LSP server installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "gopls",
        "pyright",
        "rust_analyzer",
        "lua_ls",
        "yamlls",
        "jsonls",
        "kotlin_language_server",
      },
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gr", vim.lsp.buf.references, "References")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<Leader>lr", vim.lsp.buf.rename, "Rename")
        map("<Leader>la", vim.lsp.buf.code_action, "Code action")
        map("<Leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
      end

      local default_config = {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup(default_config)
        end,
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup(vim.tbl_extend("force", default_config, {
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          }))
        end,
        ["gopls"] = function()
          lspconfig.gopls.setup(vim.tbl_extend("force", default_config, {
            settings = {
              gopls = {
                analyses = { unusedparams = true },
                staticcheck = true,
                gofumpt = true,
              },
            },
          }))
        end,
      })
    end,
  },
}
