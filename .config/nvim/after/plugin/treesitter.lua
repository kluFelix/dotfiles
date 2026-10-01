-- Treesitter indentation for two filetypes the built-in indent scripts handle
-- poorly: htmlangular (Angular's @if/@for/... blocks, via the angular parser)
-- and typescript (replaces the removed lua/tsindent.lua).
-- Parser resolves from filetype, so no start() -- highlighting is left untouched.
require('nvim-treesitter').install({
  'html',
  'angular',
  'typescript'
})
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Treesitter indent for Angular templates and TypeScript',
  pattern = { 'htmlangular', 'typescript' },
  callback = function(args)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
