local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Reload file when changed externally
autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = augroup("checktime", { clear = true }),
  command = "checktime",
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Auto-save on focus lost
autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("auto_save", { clear = true }),
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.fn.expand("%") ~= "" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! write")
      end)
    end
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with q
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = { "help", "man", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})
