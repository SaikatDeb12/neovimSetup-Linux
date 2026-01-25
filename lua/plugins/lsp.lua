-- LSP configuration for Neovim with diagnostic display enhancements
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{
			"j-hui/fidget.nvim",
			opts = {
				notification = {
					window = {
						winblend = 0,
					},
				},
			},
		},
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		-- Configure LSP diagnostics
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				source = "always",
				format = function(diagnostic)
					return string.format("%s: %s", diagnostic.source, diagnostic.message)
				end,
			},
			signs = {
				active = true,
				values = {
					{ name = "DiagnosticSignError", text = "" },
					{ name = "DiagnosticSignWarn", text = "" },
					{ name = "DiagnosticSignHint", text = "" },
					{ name = "DiagnosticSignInfo", text = "" },
				},
			},
			update_in_insert = false,
			underline = true,
			severity_sort = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})
		-- Key mappings on LSP attach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
			end,
		})
		-- Set up capabilities
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
		-- Server configurations
		local servers = {
			gopls = {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						completeUnimported = true,
						usePlaceholders = true,
						analyses = {
							unusedparams = true,
							shadow = true,
							nilness = true,
							unusedwrite = true,
							embed = true,
						},
						staticcheck = true,
						gofumpt = true,
						semanticTokens = true,
						hoverKind = "FullDocumentation",
						experimentalPostfixCompletions = true,
						linksInHover = true,
						codelenses = {
							references = true,
							implementations = true,
						},
						directoryFilters = { "-vendor" },
					},
				},
				on_attach = function(client, bufnr)
					-- Enable inlay hints when available
					if client.supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
					-- Auto-format on save
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								async = false,
							})
						end,
					})
				end,
			},
			ts_ls = {},
			ruff = {},
			pylsp = {
				settings = {
					pylsp = {
						plugins = {
							pyflakes = { enabled = false },
							pycodestyle = { enabled = false },
							autopep8 = { enabled = false },
							yapf = { enabled = false },
							mccabe = { enabled = false },
							pylsp_mypy = { enabled = false },
							pylsp_black = { enabled = false },
							pylsp_isort = { enabled = false },
						},
					},
				},
			},
			html = { filetypes = { "html", "twig", "hbs" } },
			cssls = {},
			tailwindcss = {},
			dockerls = {},
			terraformls = {},
			sqlls = {
				settings = {
					sqlLanguageServer = {
						-- General settings
						completion = {
							resolveColumnName = true,
							disableSnippets = false,
							enable = true,
						},
						diagnostics = {
							enable = true,
							fatalErrorsAsWarnings = false,
							-- Disable some built-in diagnostics that might conflict
							disabled = { "missing-return" },
							-- Syntax error detection
							syntaxErrorRecovery = true,
						},
						-- Execution settings (optional)
						execute = {
							enable = true,
						},
						-- Formatting settings (optional)
						format = {
							enable = true,
							indentSize = 2,
							keywordCase = "upper",
							identifierCase = "lower",
							placeSelectStatementReferencesOnNewLine = true,
							useTSqlFormatter = false,
						},
						-- Schema suggestions
						schema = {
							suggestions = {
								enable = true,
							},
						},
						-- Intellisense settings
						intellisense = {
							enable = true,
							enableSuggestions = true,
							suggestKeywords = true,
							suggestFunctions = true,
							suggestTables = true,
							suggestViews = true,
							suggestProcedures = true,
							suggestColumns = true,
							quickInfo = true,
						},
					},
				},
				-- File types this server should handle
				filetypes = { "sql", "mysql", "postgresql" },
				-- Optional: Configure on attach for SQL-specific keymaps
				on_attach = function(client, bufnr)
					-- SQL-specific keymaps can be added here
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "SQL: " .. desc })
					end
					-- Example: Execute current SQL statement
					map("<leader>se", function()
						-- You could integrate with a SQL runner plugin here
						vim.notify("Execute SQL - integrate with your preferred SQL runner")
					end, "[S]QL [E]xecute")
					-- Example: Format SQL
					map("<leader>sf", function()
						vim.lsp.buf.format({ async = true })
					end, "[S]QL [F]ormat")
				end,
			},
			jsonls = {},
			yamlls = {},
			lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
						diagnostics = {
							globals = { "vim" },
							disable = { "missing-fields" },
						},
						format = {
							enable = false,
						},
					},
				},
			},
		}
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
			handlers = {
				function(server_name)
					local server_config = servers[server_name] or {}
					server_config.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
					require("lspconfig")[server_name].setup(server_config)
				end,
			},
		})
		-- Ensure tools are installed
		local ensure_installed = {
			"stylua",
			"prettier",
			"eslint_d",
			"shfmt",
			"clang-format",
			"sql-formatter", -- Add SQL formatter for better formatting
		}
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
	end,
}
