require('nvim-web-devicons').setup()
require("quesnok")


local lsp=require("lsp-zero")
lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

lsp.default_keymaps({buffer = bufnr})
lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gD", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "gd", function() vim.lsp.buf.declaration() end, opts)
  vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
  vim.keymap.set("n", "ge", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

local lspconfig=require("lspconfig")
lspconfig.jedi_language_server.setup({
    init_options = {
        completion = {
                fuzzy = true,
                eager = true,
        },    workspace = {
        symbols = {
            ignoreFolders={}
            }
        }
    },

    on_attach = function(client, bufnr)
        local lsp_zero = require('lsp-zero')
        lsp_zero.on_attach(client, bufnr)
        -- Rebind the "textDocument/implementation" keybinding
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = 'Go to references' })
    end
})

-- Enable the following language servers
local servers = { 'jedi_language_server', 'lua_ls', 'typescript-tools', 'zls', 'jsonls' }
for _, s in ipairs(servers) do
  lspconfig[s].setup {
    on_attach = lsp.on_attach,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  }
end

lspconfig.lua_ls.setup({
on_init = function(client)
    local path = client.workspace_folders[1].name
    if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
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

lspconfig.jsonls.setup({
    filetypes = {"json", "jsonc"},
    init_options = {provideFormatter = true}
})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.locales",
    command = "set filetype=json"
})

lspconfig.shopify_theme_ls.setup({
    cmd = { "/usr/bin/shopify", "theme", "language-server" },
    root_dir = require('lspconfig.util').root_pattern(".git", "config.yml"),
    on_attach = lsp.on_attach,
})

require('lspconfig').zls.setup({})
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({}),
})

require('lspconfig').cucumber_language_server.setup({})
