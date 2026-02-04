vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.smartindent = true
vim.opt.wrap = false
-- enable copy to clippboard
vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }


vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = "#E6C384",
    bold = true,
})

vim.api.nvim_set_hl(0, "CursorLine", {
    bg = "#2A2A2A",
})

