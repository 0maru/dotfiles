return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
    },
    on_attach = function(buf)
      local gs = require('gitsigns')
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
      end
      map('n', ']h', gs.next_hunk, 'Next hunk')
      map('n', '[h', gs.prev_hunk, 'Previous hunk')
      map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
      map('n', '<leader>gS', gs.stage_hunk, 'Stage hunk')
      map('n', '<leader>gb', gs.blame_line, 'Blame line')
    end,
  },
}
