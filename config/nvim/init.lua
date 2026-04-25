-- `nvim .` の初期ディレクトリ表示を Oil に統一するため、起動直後の netrw を無効化する
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- lazy.nvim 読み込み前のディレクトリ起動は Oil の自動 hijack が間に合わないことがある。
-- `nvim .` のように引数がディレクトリ 1 件だけのときは、VimEnter で明示的に Oil を開く。
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.fn.argc() ~= 1 then
      return
    end

    local path = vim.fn.argv(0)
    if vim.fn.isdirectory(path) == 0 then
      return
    end

    vim.schedule(function()
      vim.cmd.enew({ bang = true })
      require("oil").open(path)
    end)
  end,
})

require("config.autocmds")
require("config.keymaps")
require("config.lazy")
require("config.lsp")
require("config.options")
