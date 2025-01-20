return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

    use({
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        run = "make install_jsregexp"
    })
  -- fuzzy finder --
  use {'nvim-telescope/telescope.nvim',
  requires = {{'nvim-lua/plenary.nvim' }}
}
    use 'nvim-tree/nvim-web-devicons'
  -- status line -- 
  use {'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
}
  -- git sti --

  use('tpope/vim-fugitive')

  -- undotree --
  use('mbbill/undotree')
  -- treesitter --
  use('nvim-treesitter/nvim-treesitter', {run= ':TSUpdate'})
  use('nvim-treesitter/nvim-treesitter-context')
  -- lsp-zero --
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
        -- LSP Support
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},
        {'neovim/nvim-lspconfig'},
        -- Autocompletion
        {'hrsh7th/nvim-cmp'},
        {'hrsh7th/cmp-buffer'},
        {'hrsh7th/cmp-path'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/cmp-nvim-lua'},
    }
}
    -- git blame
use {'f-person/git-blame.nvim'}

    -- typescript
use {
        "pmizio/typescript-tools.nvim",
        requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("typescript-tools").setup({})
        end,
}

  -- dark theme --
  use {"olimorris/onedarkpro.nvim"}

end)

