return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	lazy = false,
	opts = {
		close_if_last_window = true,
		window = {
			position = "float",
			width = math.floor(vim.o.columns * 0.8),
			height = math.floor(vim.o.lines * 0.8),
			popup = { -- Settings for floating window
				relative = "editor",
				border = "rounded",
				position = "50%", -- Center the window
			},
			mappings = {
				["<esc>"] = "close_window",
			},
		},
		filesystem = {
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_by_name = {
					"node_modules",
					".venv",
					".git",
					"__pycache__",
					"dist",
					"build",
					"target",
					"yarn.lock",
					"package-lock.json",
				},
				never_show = {
					".DS_Store",
					"thumbs.db",
				},
			},
		},
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)
	end,
}
