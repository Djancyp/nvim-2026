return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000, -- load before other plugins
		opts = {
			style = "night", -- storm | moon | night | day
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
