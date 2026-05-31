return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format({ async = true, lsp_format = 'never' })
      end,
      mode = { 'n', 'v' },
      desc = 'Format buffer (conform)',
    },
  },
  opts = {
    -- conform 内蔵の biome フォーマッタは `biome format --stdin-file-path=$FILENAME` を実行し、
    -- node_modules/.bin/biome をプロジェクトローカルから自動解決する。
    -- これによりプロジェクトごとの biome バージョンと biome.json の設定が正しく反映される。
    formatters_by_ft = {
      javascript = { 'biome' },
      javascriptreact = { 'biome' },
      typescript = { 'biome' },
      typescriptreact = { 'biome' },
      json = { 'biome' },
      jsonc = { 'biome' },
      css = { 'biome' },
      scss = { 'biome' },
    },
    format_on_save = {
      timeout_ms = 2000,
      -- LSP format には絶対にフォールバックさせない。
      -- biome が見つからない場合はフォーマットを諦める方が安全（tsserver 等が暴走するのを防ぐ）。
      lsp_format = 'never',
    },
  },
}
