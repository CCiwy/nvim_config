require("quesnok")

-- disable_netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
--|nvim-tree.disable_netrw| `= false`
--|nvim-tree.hijack_netrw| ` = true`

-- COMPLETION SETUP
local cmp = require("cmp")
cmp.setup({
    sources = { { name = 'nvim_lsp' } },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({}),
})


-- DIAGNOSTICS
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



vim.diagnostic.config({
    virtual_text = false,  -- Disable inline virtual text (optional)
    float = {
        source = "if_many",  -- Show source of diagnostic message
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
