return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = {
      enabled = true,
    },
    notifier = {
      enabled = true,
    },
    picker = {
      enabled = true,
      exclude = {
        '.git',
        'node_modules',
        '.next'
      },
      source = {
        files = {
          hidden = true,
          ignored = true,
          never_show = {
            '.DS_Store',
            'thumbs.db'
          },
        },
      },
    },
    scroll = {
      enabled = false,
    },
  },
  keys = {
    -- ファイル検索
    { '<leader>ff', function() Snacks.picker.smart() end, desc = 'Find Files' },
    { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent Files' },
    { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    -- grep
    { '<leader>fg', function() Snacks.picker.grep() end, desc = 'Grep' },
    { '<leader>fw', function() Snacks.picker.grep_word() end, desc = 'Grep Word', mode = { 'n', 'x' } },
    -- git
    { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
    { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
    -- その他
    { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
    { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
    -- terminal
    { '<leader>tt', function() Snacks.terminal() end, desc = 'Terminal', mode = { 'n', 't'} }
  },
}
