---@type vim.lsp.Config
return {
  settings = {
    python = {
      pythonPath = ".venv/bin/python",
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
}
