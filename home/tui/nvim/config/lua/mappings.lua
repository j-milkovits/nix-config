require "nvchad.mappings"

local map = vim.keymap.set

-- save
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- vertical movement
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

--- stay centered on searches
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- delete without affecting the register
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- neovim settings
map("n", "<leader>tt", function()
  require("base46").toggle_transparency()
end)

-- lazygit
map("n", "<A-g>", function()
  require("nvchad.term").toggle {
    pos = "float",
    cmd = "lazygit",
    id = "lazygit",
    float_opts = {
      row = 0.05,
      col = 0.1,
      width = 0.8,
      height = 0.8,
      border = "single",
    },
  }
end, { desc = "Git  Lazygit (float)" })

map("t", "<A-g>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "lazygit",
  }
end, { desc = "Git  Hide Lazygit" })

-- claude code
map("n", "<A-c>", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
map("t", "<A-c>", "<cmd>ClaudeCode<cr>", { desc = "AI  Hide Claude" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume conversation" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue last conversation" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

-- add file from nvim-tree
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
  callback = function(args)
    vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeTreeAdd<cr>", {
      buffer = args.buf,
      desc = "Add file from tree",
    })
  end,
})
