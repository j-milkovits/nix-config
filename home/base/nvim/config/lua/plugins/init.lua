return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local my_cmp = require "configs.cmp"
      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, my_cmp.mapping)
      return opts
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- lsp
        "lua-language-server",
        "html-lsp",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "pyright",
        "rust-analyzer",
        "jdtls",

        -- formatter
        "stylua",
        "prettier",
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        width = 40,
        side = "left",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- defaults
        "vim",
        "lua",
        "vimdoc",

        -- web dev
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",

        -- others
        "python",
        "java",

        -- storage stuff
        "json",
        "yaml",
        "toml",
        "markdown",
      },
    },
  },

  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 15,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-e>",
        },
      },
      filetypes = {
        markdown = true,
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
      },
    },
  },

  -- claude code
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    opts = {
      focus_after_send = false,
    },
  },
}
