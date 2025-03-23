local lsp = require("lsp-zero")
local lspconfig = require("lspconfig")
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
require("quesnok")

-- telescope layout
require('telescope').setup({
    layout_config = {
      vertical = { width = 0.5 },
      -- other layout configuration here
    },
 pickers = {
    find_files = {
      theme = "dropdown",
    }
  },
})

-- Set sign icons for diagnostics
lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

-- Common on_attach function for all LSPs
local function on_attach_client(client, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "ge", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end



-- Enhanced capabilities for LSPs
local capabilities = cmp_nvim_lsp.default_capabilities()

-- LSP servers with default settings
local servers = { 'jedi_language_server', 'lua_ls', 'typescript-tools', 'eslint', 'zls', 'jsonls', 'cucumber_language_server', 'shopify_theme_ls' }


for _, server in ipairs(servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
    on_attach = on_attach_client
  }
end
lsp.on_attach = on_attach_client
-- Language-specific configurations
-- Python
lspconfig.jedi_language_server.setup({
  init_options = {
    completion = { fuzzy = true, eager = true },
    workspace = { symbols = { ignoreFolders = {} } }
  },

    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)
        -- Rebind the "textDocument/implementation" keybinding
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = 'Go to references' })
    end

})
-- Python RUFF formatting
lspconfig.ruff.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
  end,
})
lspconfig.cucumber_language_server.setup({
settings = {
    cucumber = {
        features = { "**/cypress/e2e/**/*.feature" },
        glue = { "**/cypress/e2e/**/*.ts", "**/step_definitions/**/*.ts" },
     },
    }
})

-- Lua
lspconfig.lua_ls.setup({
on_init = function(client)
    local path = client.workspace_folders[1].name
    if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
      return
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}
)

-- JSON
lspconfig.jsonls.setup({ filetypes = {"json", "jsonc"}, init_options = { provideFormatter = true } })

-- Shopify
lspconfig.shopify_theme_ls.setup({
  cmd = { "/usr/bin/shopify", "theme", "language-server" },
  root_dir = require('lspconfig.util').root_pattern(".git", "config.yml"),
})

-- Typescript formatting
lspconfig.eslint.setup({
  bin = 'eslint', -- or `eslint_d`
  code_actions = {
    enable = true,
    apply_on_save = {
      enable = true,
      types = { "directive", "problem", "suggestion", "layout" },
    },
    disable_rule_comment = {
      enable = true,
      location = "separate_line", -- or `same_line`
    },
  },
  diagnostics = {
    enable = true,
    report_unused_disable_directives = false,
    run_on = "type", -- or `save`
  },
})

-- Completion setup
cmp.setup({
  sources = { { name = 'nvim_lsp' } },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({}),
})

-- diagnostics

vim.diagnostic.config({
  virtual_text = false,  -- Disable inline virtual text (optional)
  float = {
    source = "always",  -- Show source of diagnostic message
    wrap = true,        -- Ensure long messages are wrapped
    border = "rounded", -- Add a nice border around the float window
    max_width = math.floor(vim.o.columns * 0.7), -- Limit width to avoid exceeding screen size
    scope = "cursor"
  },
})
vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*",
  callback = function()
    if #vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 }) > 0 then
      vim.diagnostic.open_float(nil, { focusable = false })
    end
  end,
})

-- Autocommands
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.locales",
  command = "set filetype=json"
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    vim.lsp.buf.format()  -- Uses tsserver or eslint
  end,
})

--vim.api.nvim_create_autocmd("BufWritePre", {
--  pattern = "*.py",
--  callback = function()
--    vim.lsp.buf.format()  -- Uses Ruff for formatting
--  end,
--})
