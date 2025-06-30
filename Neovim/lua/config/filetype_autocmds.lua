vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.keymap.set("x", "vit", ":<C-u>lua require'config.helpers'.select_inner_tag()<CR>", {
      noremap = true,
      silent = true,
      buffer = true,
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "html", "css", "json" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    -- Exit terminal insert mode with <Esc>
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = true })

    -- Optional: close terminal with Ctrl-d
    vim.keymap.set("t", "<C-d>", [[<C-\><C-n>:bd!<CR>]], { buffer = true })
  end,
})
