local function line_location()
  return string.format("%d/%d:%d", vim.fn.line("."), vim.fn.line("$"), vim.fn.virtcol("."))
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
    },
    sections = {
      lualine_z = {
        line_location,
      },
    },
  },
}
