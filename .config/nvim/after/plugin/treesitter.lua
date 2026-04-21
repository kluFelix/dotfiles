require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'vim',
    'vimdoc',
    'lua',
    'cpp',
    'c',
    'cuda',
    'nix',
    'html',
    'go',
    'elixir',
  },
  auto_install = false,
  highlight = { enable = true },
  indent = { enable = true }
}
