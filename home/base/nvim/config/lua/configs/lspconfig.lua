require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ts_ls", "tailwindcss", "pyright", "rust_analyzer", "jdtls" }
vim.lsp.enable(servers)
