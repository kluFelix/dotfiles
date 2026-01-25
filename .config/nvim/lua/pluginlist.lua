return {
    -- Theme
    {
        "polirritmico/monokai-nightasty.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme monokai-nightasty")
            for _, group in ipairs({ "Normal", "NormalFloat", "NormalNC", "SignColumn", "MsgArea" }) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end
    },

    -- LSP
    "neovim/nvim-lspconfig",

    -- lazydev configures LuaLS for editing Neovim config
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- code completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",

            "hrsh7th/cmp-nvim-lsp",
        },
    },

    -- Treesitter "parser generator tool to build syntax tree"
    -- -> better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    -- Telescope (extendeble fuzzy finder)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- UndoTree
    "mbbill/undotree",

    -- Vim Fugitive - Git integration
    "tpope/vim-fugitive",

    -- Git Signs (diff indicators)
    "lewis6991/gitsigns.nvim",

    -- Vim Be Good
    "ThePrimeagen/vim-be-good",
}
