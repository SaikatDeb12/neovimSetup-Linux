return {
	-- Additional Go tools
	{
		"olexsmir/gopher.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("gopher").setup({
				commands = {
					go = "go",
					gomodifytags = "gomodifytags",
					gotests = "gotests",
					impl = "impl",
					iferr = "iferr",
				},
			})

			-- Keymaps for gopher.nvim
			vim.keymap.set("n", "<leader>ge", "<cmd>GoIfErr<CR>", { desc = "Generate if err" })
			vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<CR>", { desc = "Run go test" })
			vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFunc<CR>", { desc = "Run go test for current function" })
			vim.keymap.set("n", "<leader>gg", "<cmd>GoGenerate<CR>", { desc = "Run go generate" })
		end,
	},

	-- Go tags management
	{
		"fatih/vim-go",
		ft = "go",
		config = function()
			-- Disable vim-go's auto formatting (we use null-ls)
			vim.g.go_fmt_autosave = 0
			vim.g.go_imports_autosave = 0
			vim.g.go_mod_fmt_autosave = 0

			-- Enable syntax highlighting
			vim.g.go_highlight_types = 1
			vim.g.go_highlight_fields = 1
			vim.g.go_highlight_functions = 1
			vim.g.go_highlight_function_calls = 1
			vim.g.go_highlight_operators = 1
			vim.g.go_highlight_extra_types = 1
			vim.g.go_highlight_build_constraints = 1
			vim.g.go_highlight_generate_tags = 1
		end,
	},
}
