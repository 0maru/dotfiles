return {
  'saghen/blink.cmp',
  version = '*',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'rafamadriz/friendly-snippets',
  },
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = {
        auto_show = true,
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      cmdline = {},
    },
    signature = {
      enabled = true,
    },
  },
}
