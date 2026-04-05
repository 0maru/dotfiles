return {
  'shellRaining/hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local exclude_ft = {
      yaml = true,
      yml = true,
      sql = true
    }

    require('hlchunk').setup({
      chunk = {
        enable = true,
        delay = 0,
        exclude_filetypes = exclude_ft
      },
      indent = {
        enable = true,
        exclude_filetypes = exclude_ft
      },
      line_num = {
        enable = true,
        exclude_filetypes = exclude_ft
      }
    })
  end
}
