-- on_attach -> only executes as soon as LS starts and connects to nvim
local on_attach = function(_, bufnr)
    -- helper function `bufmap`
    local bufmap = function(keys, func)
        vim.keymap.set('n', keys, func, { buffer = bufnr })
    end

    -- key bindings
    bufmap('<leader>r', vim.lsp.buf.rename)
    bufmap('<leader>a', vim.lsp.buf.code_action)

    bufmap('gd', vim.lsp.buf.definition)
    bufmap('gD', vim.lsp.buf.declaration)
    bufmap('gI', vim.lsp.buf.implementation)
    bufmap('<leader>D', vim.lsp.buf.type_definition)

    -- lsp integration with telescope
    bufmap('gr', require('telescope.builtin').lsp_references)
    bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
    bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

    -- hover menu
    bufmap('K', vim.lsp.buf.hover)

    -- custom `Format` command to format code
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, {})
end

-- tells server what Neovim supports
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)


-- Apply above settings to all LSPs
vim.lsp.config('*', {
    on_attach = on_attach,
    capabilities = capabilities,
})


vim.lsp.enable({
    'clangd',
    'gopls',
    'nil',
    'lua_ls',
})

-- requires "clang-tools"
vim.lsp.config('clangd', {
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    cmd = {
        "clangd",
        "--query-driver=/nix/store/*/bin/clang*",
    },
})

-- requires "gopls"
vim.lsp.config('gopls', {
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
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

-- requires "nil"
vim.lsp.config('nil', {
    filetypes = { 'nix' },
    cmd = {'nil'},
    settings = {
        ['nil'] = {
            nix = {
                flake = {
                    autoArchive = true,
                },
            },
        },
    },
})

-- Setup lazydev
require('lazydev').setup()

-- requires "lua_lanugage-server"
vim.lsp.config('lua_ls', {
    filetypes = { 'lua' },
    cmd = { 'lua-language-server' },
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

