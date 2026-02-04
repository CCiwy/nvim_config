local lsp = vim.lsp
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lsp_util = require("lspconfig.util")
require("quesnok")

-- disable_netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
--|nvim-tree.disable_netrw| `= false`
--|nvim-tree.hijack_netrw| ` = true`
-- telescope layout

require('telescope').setup({
defaults = {
    layout_config = {
      horizontal = {
            width = 0.95,
            height = 0.6,
            prompt_position = 'top',
        },
      mirror = true,
    },
  },
 pickers = {
    find_files = {
      theme = "dropdown",
      layout_strategy = 'vertical',
      layout_config = {
        width = function(_, cols, _) return cols end,                 -- all columns
        height = function(_, _, lines) return math.floor(lines * .95) end,
        preview_height = 0.5,
        preview_cutoff = 0,
        },
    }
  },
})

local diagnostic_signs = {
  Error = '✘',
  Warn = '▲',
  Hint = '⚑',
  Info = '»',
}

for sign, icon in pairs(diagnostic_signs) do
  local hl = 'DiagnosticSign' .. sign
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = ''})
end

-- Common on_attach function for all LSPs
local function on_attach_client(client, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "ge", function() vim.diagnostic.jump({count= 1}) end, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

local function extend_on_attach(extra)
  if not extra then
    return on_attach_client
  end
  return function(client, bufnr)
    on_attach_client(client, bufnr)
    extra(client, bufnr)
  end
end



-- Enhanced capabilities for LSPs
local capabilities = cmp_nvim_lsp.default_capabilities()

-- LSP servers enabled by default
local servers = {
  'jedi_language_server',
  'lua_ls',
  'eslint',
  'zls',
  'jsonls',
  'cucumber_language_server',
  'shopify_theme_ls',
  'ruff',
  'ocamllsp'
}

lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach_client,
})

lsp.config('jedi_language_server', {
  init_options = {
    completion = { fuzzy = true, eager = true },
    workspace = { symbols = { ignoreFolders = {} } }
  },

  on_attach = extend_on_attach(function(_, bufnr)
    -- Rebind the "textDocument/implementation" keybinding
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = 'Go to references' })
  end),
})
-- Python RUFF formatting
lsp.config('ruff', {
  on_attach = extend_on_attach(function(client)
    client.server_capabilities.documentFormattingProvider = true
  end),
})

lsp.config('cucumber_language_server', {
settings = {
    cucumber = {
        features = { "**/cypress/e2e/**/*.feature" },
        glue = { "**/cypress/e2e/**/*.ts", "**/step_definitions/**/*.ts" },
     },
    }
})

-- Lua
lsp.config('lua_ls', {
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
})

-- JSON
lsp.config('jsonls', { filetypes = {"json", "jsonc"}, init_options = { provideFormatter = true } })

-- Shopify
lsp.config('shopify_theme_ls', {
  cmd = { "/usr/bin/shopify", "theme", "language-server" },
  root_dir = lsp_util.root_pattern(".git", "config.yml"),
})

-- ESLint.nvim helpers for formatting/code actions
require("eslint").setup({
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

--vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave" }, {
--  callback = function()
--    vim.diagnostic.hide(nil, 0) -- hide diagnostics for current buffer
--  end,
--})

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


--vim.api.nvim_create_autocmd("BufWritePre", {
--  pattern = "*.py",
--  callback = function()
--    vim.lsp.buf.format()  -- Uses Ruff for formatting
--  end,
--})

-- ESLint LSP (safe resolver)
local util = lsp_util

local function resolve_eslint_cmd(root_dir)
  local local_bin = util.path.join(root_dir, "node_modules", ".bin", "vscode-eslint-language-server")
  local global_bin = vim.fn.exepath("vscode-eslint-language-server")

  local function cmd_for(bin)
    if bin == nil or bin == "" then return nil end
    if vim.fn.executable(bin) == 1 then
      return { bin, "--stdio" }
    else
      -- not executable (or a plain JS file) → run via node
      return { "node", bin, "--stdio" }
    end
  end

  if util.path.is_file(local_bin) then
    return cmd_for(local_bin)
  end
  return cmd_for(global_bin)
end

lsp.config('eslint', {
  root_dir = util.root_pattern(
    ".eslintrc",
    ".eslintrc.mjs",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    "package.json",
    ".git"
  ),
  cmd = (function()
    local root = vim.loop.cwd()
    local cmd = resolve_eslint_cmd(root)
    return cmd or { "eslint-language-server", "--stdio" }
  end)(),
  settings = {
    format = true,
    -- set true only if you actually use flat config (eslint.config.js)
    experimental = { useFlatConfig = false },
      codeActionOnSave = {
        enable = true,
        mode = "all"
      },

  },
  on_attach = extend_on_attach(function(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          async = false,
          filter = function(srv) return srv.name == "eslint" end,
        })
      end,
    })
  end),
})

lsp.enable(servers)


require("typescript-tools").setup({
  on_attach = extend_on_attach(function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end),
  settings = {
    tsserver_max_memory = 4096,
    tsserver_file_preferences = {
      includeInlayParameterNameHints = "all",
      includeInlayVariableTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})
