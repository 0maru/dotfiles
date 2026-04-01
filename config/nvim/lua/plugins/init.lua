-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.colorscheme" },
    { import = "plugins.editor" },
    { import = "plugins.telescope" },
    { import = "plugins.treesitter" },
    { import = "plugins.lsp" },
    { import = "plugins.completion" },
    { import = "plugins.formatter" },
    { import = "plugins.git" },
    { import = "plugins.explorer" },
    { import = "plugins.ui" },
    { import = "plugins.navigation" },
  },
  defaults = { lazy = true },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
