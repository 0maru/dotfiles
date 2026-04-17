return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    -- tsserver の組み込みフォーマッタは {} にスペースを入れたり、クォートスタイル無指定など
    -- Biome (biome.json) のルールと衝突するため無効化する。
    -- フォーマットは conform.nvim 経由で biome に一本化する（plugins/editor/conform.lua 参照）。
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  },
}
