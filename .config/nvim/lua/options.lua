--------------
--- Basics ---
--------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- per-file-type overrides
local ft_options = {
    nix = { shiftwidth = 2, tabstop = 2, softtabstop = 2 },
}

vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.colorcolumn = "80"

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en", "de_de" }

-- Some settings for the diagnostic signs
-- https://www.reddit.com/r/neovim/comments/17wwels/lsp_diagnostic_signs_disappear_when_entering/
-- Use <C-w>d to show the diagnostic message in a floating window
-- vim.opt.signcolumn = "number"
vim.diagnostic.enable = true
vim.diagnostic.config {
    virtual_lines = false, -- This can quickly spamm the entire window use <C-w>d instead
    update_in_insert = true;
}


-- For automatic filetype recognition
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("IndentSettings", { clear = true }),
  callback = function(args)
    local opts = ft_options[vim.bo[args.buf].filetype]
    if opts then
      for k, v in pairs(opts) do
        vim.bo[args.buf][k] = v
      end
    end
  end,
})

-----------------
-- Keybindings --
-----------------
-- leader key space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- use J and K to move selection up and down in Visual Mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- jump 10 lines with arrow keys
vim.keymap.set("", "<Down>", "10j")
vim.keymap.set("", "<Up>", "10k")


-- keep cursor in middle when scrolling or searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- pasting without yanking
vim.keymap.set("x", "<leader>p", [["_dP]])

-- yanking to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])


------------------------
-- Pluing Keybindings --
------------------------

-- UndoTree --
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)


-- cmp Code Completion 
--[[ set in ../after/plugins/cmp.lua
['<C-n>'] = cmp.mapping.select_next_item(),
['<C-p>'] = cmp.mapping.select_prev_item(),
['<C-d>'] = cmp.mapping.scroll_docs(-4),
['<C-f>'] = cmp.mapping.scroll_docs(4),
['<C-Space>'] = cmp.mapping.complete {},
['<CR>'] = cmp.mapping.confirm {
    behavior = cmp.ConfirmBehavior.Replace,
    select = true,
},
['<Tab>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
    else
        fallback()
    end
end, { 'i', 's' }),
['<S-Tab>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
    else
        fallback()
    end
end, { 'i', 's' }),
]]


-- Telescope --
--[[ set in ../after/plugins/telescope.lua
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
]]

-- LSP --
--[[ set in ../after/plugins/lsp.lua
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
]]
