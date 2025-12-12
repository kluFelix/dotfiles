-- requires "clang-tools"
vim.lsp.enable('clangd')
vim.lsp.config('clangd', {
    cmd = {
        "clangd",
        "--query-driver=/nix/store/*/bin/clang*",
    },
})

--[[
require('lazydev').setup()
vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {})
]]
