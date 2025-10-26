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

  -- hover menue
  bufmap('K', vim.lsp.buf.hover)

  -- custom `Format` command to format code
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, {})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- setup mason
require("mason").setup()
require('mason-lspconfig').setup({
    automatic_enable = true,
    automatic_installation = true,
    ensure_installed = {
        'clangd',
        'omnisharp',
        'lua_ls',
        'jdtls',
        'html',
        'pylsp',
        'intelephense',
        'nil_ls',
    },
    handlers = {
        -- fallback for undefined LS
        function(server_name)
            require("lspconfig")[server_name].setup {
                on_attach = on_attach,
                capabilities = capabilities,
            }
        end,

        -- LUA
        ["lua_ls"] = function()
            require('lazydev').setup()
            require('lspconfig').lua_ls.setup {
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                }
            }
        end,

        -- C#
        ["omnisharp"] = function()
            require('lspconfig').omnisharp.setup {
                filetypes = { "cs", "vb" },
                root_dir = require('lspconfig').util.root_pattern("*.csproj", "*.sln"),
                on_attach = on_attach,
                capabilities = capabilities,
                enable_roslyn_analyzers = true,
                analyze_open_documents_only = true,
                enable_import_completion = true,
            }
        end,

        -- C, C++
        ["clangd"] = function()
            require('lspconfig').clangd.setup {
                cmd = { "clangd", "--enable-config" },
                on_attach = on_attach,
                capabilities = capabilities,
            }
        end,

        -- Nix
        ["nil_ls"] = function()
            require("lspconfig").nil_ls.setup {
                on_attach = on_attach,
                capabilities = capabilities,
                root_dir = require("lspconfig.util").root_pattern("flake.nix"),
                -- nil-specific settings
                settings = {
                    nix = {
                        flake = {
                            -- auto-fetch missing flake inputs on start-up
                            autoArchive = true,
                        };
                    },
                },
            }
        end,
    },
})
