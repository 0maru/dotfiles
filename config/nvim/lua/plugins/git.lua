return {
  -- Inline git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Previous hunk")
        map("n", "<Leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<Leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<Leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<Leader>gb", gs.blame_line, "Blame line")
      end,
    },
  },

  -- Lazygit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<Leader>gg", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },
}
