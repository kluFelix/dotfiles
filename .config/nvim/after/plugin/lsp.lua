-- requires "clang-tools"
vim.lsp.enable('clangd')
vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--query-driver=/nix/store/*/bin/clang*",
    },
})

-- Go LSP configuration (without Mason)
vim.lsp.enable('gopls')
vim.lsp.config('gopls', {
    cmd = {"gopls"},
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

--[[
require('lazydev').setup()
vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {})
]]
