return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		-- For better Go support
		"nvim-treesitter/nvim-treesitter-textobjects",
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- Safely require the module with error handling
		local ok, configs = pcall(require, "nvim-treesitter.configs")
		if not ok then
			vim.notify("nvim-treesitter.configs not found, skipping setup", vim.log.levels.WARN)
			return
		end
		configs.setup({
			ensure_installed = {
				-- Go should be first for priority
				"go",
				"gomod",
				"gowork",
				"gosum",
				-- Other languages
				"lua",
				"python",
				"javascript",
				"typescript",
				"vimdoc",
				"vim",
				"regex",
				"terraform",
				"sql",
				"dockerfile",
				"toml",
				"json",
				"java",
				"groovy",
				"gitignore",
				"graphql",
				"yaml",
				"make",
				"cmake",
				"markdown",
				"markdown_inline",
				"bash",
				"tsx",
				"css",
				"html",
				"cpp",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = {
				enable = true,
				disable = { "ruby", "python" },
			},
			-- Text objects for better editing
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						-- Go-specific text objects
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["ab"] = "@block.outer",
						["ib"] = "@block.inner",
					},
				},
			},
			-- Context-aware commenting
			context_commentstring = {
				enable = true,
				enable_autocmd = false,
			},
			-- Incremental selection
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn",
					node_incremental = "grn",
					scope_incremental = "grc",
					node_decremental = "grm",
				},
			},
		})
		-- Additional Go-specific highlighting
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "go",
			callback = function()
				-- Set comment string for Go
				vim.bo.commentstring = "// %s"
			end,
		})
	end,
}
