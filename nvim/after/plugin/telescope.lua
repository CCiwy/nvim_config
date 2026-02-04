local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>gR', builtin.grep_string, {})
vim.keymap.set('n', '<leader>gr', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end
)
vim.keymap.set('n', '<leader>bb', builtin.buffers, {})
vim.keymap.set('n', '<leader>q', ':bd<CR>', {noremap = true})

-- Remap "move to left split" to Ctrl+h
vim.keymap.set('n', '<C-h>', '<C-w>h')
-- Remap "move to right split" to Ctrl+l
vim.keymap.set('n', '<C-l>', '<C-w>l')
-- Remap "move to top split" to Ctrl+k
vim.keymap.set('n', '<C-k>', '<C-w>k')
-- Remap "move to bottom split" to Ctrl+j
vim.keymap.set('n', '<C-j>', '<C-w>j')


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
                preview_height = 0.65,
                preview_cutoff = 0,
            },
        }
    },
})
