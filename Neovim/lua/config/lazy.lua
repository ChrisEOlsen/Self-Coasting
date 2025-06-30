-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "html", "css", "json" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  { "kdheepak/lazygit.nvim" },
  { "ojroques/nvim-osc52" },
	{
	"numToStr/Comment.nvim",
	config = function()
	require("Comment").setup()
	end,
	},
{
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
      formatters_by_ft = {
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
      },
    })
  end,
},
})

