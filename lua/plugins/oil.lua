return {
	"stevearc/oil.nvim",
	lazy = false, -- keep as recommended
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },

	opts = {
		default_file_explorer = false, -- VERY IMPORTANT (don't replace netrw)
		view_options = {
			show_hidden = true,
		},
		keymaps = {
			["<CR>"] = "actions.select",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["<leader>r"] = "actions.refresh",
		},
	},

	keys = {
		{ "-", "<cmd>Oil<CR>", desc = "Open Oil (parent dir)" },
	},
}
