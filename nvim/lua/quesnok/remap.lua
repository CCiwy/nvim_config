vim.g.mapleader = " "
vim.keymap.set("n", "<leader>c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })


vim.keymap.set('n', '<C-1>', ':wincmd p<CR>')
vim.keymap.set('n', '<C-2>', ':wincmd n<CR>')
