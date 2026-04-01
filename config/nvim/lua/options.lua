local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true

-- Appearance
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.showmode = false -- lualine が表示するので不要
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Behavior
opt.autoread = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
