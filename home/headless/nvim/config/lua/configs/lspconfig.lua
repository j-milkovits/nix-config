require("nvchad.configs.lspconfig").defaults()

-- pyright types, ruff lints
local servers = { "html", "cssls", "ts_ls", "tailwindcss", "pyright", "ruff", "rust_analyzer", "jdtls" }
vim.lsp.enable(servers)
