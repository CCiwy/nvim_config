vim.g.mapleader = " "
vim.keymap.set("n", "<leader>c", function()
    require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })


vim.keymap.set('n', '<C-1>', ':wincmd p<CR>')
vim.keymap.set('n', '<C-2>', ':wincmd n<CR>')


vim.keymap.set("n", "<F5>", function()
  vim.cmd("silent make")
  if #vim.fn.getqflist() > 0 then
    vim.cmd("copen")
  end
end, { desc = "Build and open quickfix" })
