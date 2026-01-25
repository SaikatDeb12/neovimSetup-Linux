-- Configuration for none-ls.nvim to manage formatters and linters
-- Updated to work with gopls for Go formatting and include all file types
return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		-- Set global Neovim options for consistent indentation and line wrapping
		vim.opt.tabstop = 4 -- Tabs are 4 spaces wide
		vim.opt.shiftwidth = 4 -- Indentation (e.g., >>) is 4 spaces
		vim.opt.expandtab = true -- Convert tabs to spaces
		vim.opt.wrap = true -- Enable line wrapping for long lines
		-- Check if null-ls is available
		local ok, null_ls = pcall(require, "null-ls")
		if not ok then
			vim.notify("null-ls not found, skipping autoformatting setup", vim.log.levels.WARN)
			return
		end
		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters
		-- Note: Go formatting is handled by gopls in lsp.lua
		-- We'll skip Go formatters here to avoid conflicts
		local sources = {
			diagnostics.checkmake,
			-- JS/TS
			formatting.prettier.with({
				filetypes = {
					"html",
					"json",
					"yaml",
					"markdown",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"css",
					"scss",
				},
				extra_args = {
					"--tab-width",
					"4", -- Use 4 spaces for indentation
					"--use-tabs",
					"false", -- Use spaces instead of tabs
				},
			}),
			formatting.stylua, -- Already defaults to 4 spaces
			formatting.shfmt.with({ args = { "-i", "4" } }),
			formatting.terraform_fmt,
			-- Python
			require("none-ls.formatting.ruff").with({ extra_args = { "--extend-select", "I" } }),
			require("none-ls.formatting.ruff_format"),
			-- C/C++
			formatting.clang_format.with({
				filetypes = { "c", "cpp", "objc", "objcpp" },
				extra_args = {
					"--style",
					"{IndentWidth: 4, TabWidth: 4, UseTab: Never}",
				},
			}),
			-- SQL
			formatting.sql_formatter.with({
				extra_args = { "--tab-width", "4" },
			}),
			-- Note: Go formatters are handled by gopls in lsp.lua
			-- Do NOT add Go formatters here to avoid conflicts
		}
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		null_ls.setup({
			sources = sources,
			on_attach = function(client, bufnr)
				-- Skip formatting for Go files (handled by gopls)
				if vim.bo[bufnr].filetype == "go" then
					return
				end
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								bufnr = bufnr,
								async = false,
								filter = function(cli)
									-- Use null-ls for formatting (except for Go)
									return cli.name == "null-ls"
								end,
							})
						end,
					})
				end
			end,
		})
		-- Set up auto-formatting for all file types
		-- Go is handled separately in lsp.lua
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("AutoFormat", { clear = true }),
			callback = function(args)
				local bufnr = args.buf
				local filetype = vim.bo[bufnr].filetype
				-- Skip Go files (handled by gopls)
				if filetype == "go" then
					return
				end
				-- Format using LSP if available
				vim.lsp.buf.format({
					bufnr = bufnr,
					async = false,
					filter = function(client)
						-- Use null-ls for non-Go files
						return client.name == "null-ls"
					end,
				})
			end,
		})
		-- Filetype-specific settings
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"html",
				"css",
				"scss",
				"json",
				"yaml",
				"markdown",
				"python",
				"lua",
				"sh",
				"bash",
				"terraform",
				"c",
				"cpp",
				"objc",
				"objcpp",
				"sql",
			},
			callback = function()
				-- Enable auto-formatting for these file types
				vim.b.autoformat = true
			end,
		})
	end,
}
