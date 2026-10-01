require "options"
require "mdformat"

-- vim-fugitive only defines `:G` when it doesn't already exist, so claiming the
-- command before plugins load is the sanctioned way to take it over.
-- `:G` with no arguments (the status buffer) opens vertically, but only when the
-- editor fits two 'colorcolumn' panes; otherwise it keeps the horizontal default.
-- Anything else (`:G diff`, `:G log`, `:G!`, `:0G`, Visual-`:'<,'>G` staging,
-- `:tab G`, or an explicit modifier) falls through to fugitive's defaults.
vim.cmd([[
  command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete G
        \ exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0,
        \   empty("<mods>") && empty(<q-args>) && <count> < 0 && !<bang>0
        \     ? (&columns >= 2 * max([str2nr(&colorcolumn), 80]) ? "vertical" : "")
        \     : "<mods>", <q-args>)
]])

require "plugins"
