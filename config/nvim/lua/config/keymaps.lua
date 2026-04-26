vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- プラグイン読込前でも壊れないよう、実行時に smart-splits を解決する
local function smart_move(direction)
  return function()
    require("smart-splits")[direction]()
  end
end

-- 保存 / 終了
map("n", "<Leader>w", "<Cmd>w<CR>", { desc = "Save" })
map({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save" })
map("n", "<Leader>q", "<Cmd>q<CR>", { desc = "Quit" })

-- クリップボード / レジスタ
map({ "n", "v" }, "<Leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<Leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<Leader>d", [["_d]], { desc = "Delete without yanking" })

-- コマンドラインを Shift なしで開く
map({ "n", "v" }, ";", ":", { desc = "Enter command-line mode" })
map({ "n", "v" }, ":", ";", { desc = "Repeat latest f/t search" })

-- 折り返し行での移動を改善
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- smart-splits 経由で Neovim と WezTerm のペイン移動を統一
map("n", "<C-h>", smart_move("move_cursor_left"), { desc = "Move to left split" })
map("n", "<C-j>", smart_move("move_cursor_down"), { desc = "Move to lower split" })
map("n", "<C-k>", smart_move("move_cursor_up"), { desc = "Move to upper split" })
map("n", "<C-l>", smart_move("move_cursor_right"), { desc = "Move to right split" })

-- バッファの移動
map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<Leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })

-- 検索ハイライトを消去
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- ビジュアルモードでのインデント改善
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 行を上下に移動
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- 診断メッセージの移動
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<Leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
