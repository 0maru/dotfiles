return {
  'HakonHarnes/img-clip.nvim',
  event = 'VeryLazy',
  opts = {
    default = {
      dir_path = 'assets',
      relative_to_current_file = false,
      prompt_for_file_name = true,
      shiw_dir_path_in_prompt = true,
    },
    filetypes = {
      markdown = {
        url_encode_path = true,
        templte = '![$CURSOR]($FILE_PATH)'
      }
    }
  },
  keys = {
    { '<leader>p', '<cmd>PasteImage<cr>', desc = 'Paste image from clipboard' },
  },
}
