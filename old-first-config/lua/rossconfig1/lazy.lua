print("lazy file loaded");

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy/nvim.git",
		"--branch=stable",
		lazypath,
	});
end
vim.opt.rtp:prepend(lazypath);

require("lazy").setup({
    {
	"bluz71/vim-nightfly-guicolors",
	priority = 1000,
	config = function()
		vim.cmd([[colorscheme nightfly]])
	end,
    },
    "folke/tokyonight.nvim",
    {"nvim-lua/plenary.nvim", lazy = false;},
    {"nvim-telescope/telescope.nvim"},
    "rose-pine/neovim",
    "folke/trouble.nvim",
    "nvim-treesitter/nvim-treesitter",
    "RRethy/base16-nvim",

});






