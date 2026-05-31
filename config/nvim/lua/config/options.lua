local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true

-- 外観
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.showmode = false -- lualine が表示するので不要
opt.wrap = false

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 動作
opt.autoread = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.fixeol = true
opt.endofline = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.listchars = { tab = "→ ", trail = "·", eol = "↲", nbsp = "␣", space = "·" }
opt.list = true

-- 補完
opt.completeopt = { "menu", "menuone", "noselect" }

vim.filetype.add({
  extension = {
    mdx = 'markdown.mdx'
  }
})

vim.o.pumborder = 'rounded'
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'fuzzy', 'popup' }

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

local orig_complete_set = vim.api.nvim__complete_set
vim.api.nvim__complete_set = function(...)
  local result = orig_complete_set(...)
  if result and result.winid then
    pcall(vim.api.nvim_win_set_config, result.winid, { border = 'rounded' })
  end
  return result
end
