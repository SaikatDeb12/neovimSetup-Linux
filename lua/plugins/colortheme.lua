return {
	{
		"sainnhe/sonokai",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.sonokai_style = "andromeda"
			vim.g.sonokai_transparent_background = 1
		end,
	},
	{
		"xiantang/darcula-dark.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"ribru17/bamboo.nvim",
		config = function()
			require("bamboo").setup({
				transparent = false, -- Built-in option
				colors = {
					-- bg = "#1e1e1e90", -- Background with 90% opacity
					bg = "#1e1e1e50",
				},
			})
		end,
	},
	{
		{
			"folke/tokyonight.nvim",
			opts = {
				style = "moon",
				transparent = true, -- Built-in option
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
			},
		},
	},
	{
		"olimorris/onedarkpro.nvim",
		config = function()
			require("onedarkpro").setup({
				options = {
					transparency = true, -- Built-in transparency
				},
			})
		end,
	},
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		opts = function()
			return {
				transparent = true,
			}
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		-- "morhetz/gruvbox",
	},
}
