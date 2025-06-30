vim.g.mapleader = " "
vim.opt.relativenumber = true
vim.opt.number = true
require("config.lazy")
require("config.keymaps")
require("config.filetype_autocmds")
-- Clear out any default scheme
vim.cmd [[
  autocmd ColorScheme * highlight Normal guibg=none ctermbg=none
  autocmd ColorScheme * highlight NonText guibg=none ctermbg=none
]]

vim.opt.termguicolors = false
vim.opt.wrap = false
