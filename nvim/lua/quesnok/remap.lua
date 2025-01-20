vim.g.mapleader = " "
vim.keymap.set("n", "<leader>o", vim.cmd.Ex)
vim.keymap.set("n", "<leader>c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })
