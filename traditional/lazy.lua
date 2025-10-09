-- This may need to change
-- Only plugin declarations here. Actual config lives in lua/plugins/*.lua (required by init.lua)
return {
  { "neovim/nvim-lspconfig" },
  { "folke/neodev.nvim" },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "numToStr/Comment.nvim" },
  { "ellisonleao/gruvbox.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim" },
}
