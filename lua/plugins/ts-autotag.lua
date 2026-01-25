return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			-- Configure nvim-treesitter
			local treesitter = require("nvim-treesitter.configs")
			treesitter.setup({
				-- Ensure required parsers are installed
				ensure_installed = {
					"html",
					"javascript",
					"typescript",
					"tsx",
					"vue",
					"svelte",
					"xml",
				},
				-- Enable syntax highlighting
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				-- Enable indentation
				indent = {
					enable = true,
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			local status_ok, autotag = pcall(require, "nvim-ts-autotag")
			if not status_ok then
				print("Failed to load nvim-ts-autotag")
				return
			end

			autotag.setup({
				opts = {
					enable = true, -- Enable autotagging
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = true, -- Auto close on trailing </
				},
				-- Use per_filetype_config for better TSX support
				per_filetype_config = {
					["html"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["javascript"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["typescript"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["javascriptreact"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["typescriptreact"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["vue"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["svelte"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
					["xml"] = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
				},
			})

			-- Optional: Add keymap for manual tag closing
			vim.keymap.set("i", "<C-c>", "<Plug>(autotag-close)", { silent = true })

			-- Ensure correct filetype detection for TSX
			vim.filetype.add({
				extension = {
					tsx = "typescriptreact",
				},
			})
		end,
	},
}
