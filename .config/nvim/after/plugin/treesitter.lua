require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'vim',
        'vimdoc',
        'lua',
        'cpp' ,
        'c',
        'nix',
        'html',
    },
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true }
}
