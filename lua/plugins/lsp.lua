-- LSP configuration for Neovim with diagnostic display enhancements
-- This file sets up nvim-lspconfig, mason.nvim, and related plugins to manage LSP servers,
-- and includes diagnostic configuration to display error/warning signs, virtual text, and underlines.

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		{ "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
		-- mason-lspconfig:
		-- - Bridges the gap between LSP config names (e.g. "lua_ls") and actual Mason package names (e.g. "lua-language-server").
		-- - Used here only to allow specifying language servers by their LSP name (like "lua_ls") in `ensure_installed`.
		-- - It does not auto-configure servers — we use vim.lsp.config() + vim.lsp.enable() explicitly for full control.
		"mason-org/mason-lspconfig.nvim",
		-- mason-tool-installer:
		-- - Installs LSPs, linters, formatters, etc. by their Mason package name.
		-- - We use it to ensure all desired tools are present.
		-- - The `ensure_installed` list works with mason-lspconfig to resolve LSP names like "lua_ls".
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		{
			"j-hui/fidget.nvim",
			opts = {
				notification = {
					window = {
						winblend = 0, -- Background color opacity in the notification window
					},
				},
			},
		},

		-- Allows extra capabilities provided by nvim-cmp
		"hrsh7th/cmp-nvim-lsp",

		-- Additional Go tools
		"mfussenegger/nvim-dap", -- Debug Adapter Protocol
		"leoluz/nvim-dap-go", -- Go-specific DAP configuration
	},
	config = function()
		-- Configure LSP diagnostics to display signs, virtual text, and underlines
		-- Using Nerd Font compatible icons for warnings, errors, hints, and info
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●", -- Symbol for virtual text (can be customized)
				source = "always", -- Show source of diagnostic
				format = function(diagnostic)
					return string.format("%s: %s", diagnostic.source, diagnostic.message)
				end,
			},
			signs = {
				active = true,
				values = {
					{ name = "DiagnosticSignError", text = "" }, -- Error icon
					{ name = "DiagnosticSignWarn", text = "" }, -- Warning icon
					{ name = "DiagnosticSignHint", text = "" }, -- Hint icon
					{ name = "DiagnosticSignInfo", text = "" }, -- Info icon
				},
			},
			update_in_insert = false, -- Avoid updating diagnostics in insert mode
			underline = true, -- Underline code with diagnostics
			severity_sort = true, -- Sort diagnostics by severity
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				-- Create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Jump to the definition of the word under your cursor.
				-- This is where a variable was first declared, or where a function is defined, etc.
				-- To jump back, press <C-t>.
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

				-- Find references for the word under your cursor.
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				-- Useful when your language has ways of declaring types without an actual implementation.
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

				-- Jump to the type of the word under your cursor.
				-- Useful when you're not sure what type a variable is and you want to see
				-- the definition of its *type*, not where it was *defined*.
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

				-- Fuzzy find all the symbols in your current document.
				-- Symbols are things like variables, functions, types, etc.
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

				-- Fuzzy find all the symbols in your current workspace.
				-- Similar to document symbols, except searches over your entire project.
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				-- Rename the variable under your cursor.
				-- Most Language Servers support renaming across files, etc.
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				-- For example, in C this would take you to the header.
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				-- Go-specific keymaps
				if vim.bo[event.buf].filetype == "go" then
					-- Run go test for current package
					map("<leader>gt", function()
						vim.cmd("!go test ./...")
					end, "[G]o [T]est")

					-- Run go build
					map("<leader>gb", function()
						vim.cmd("!go build")
					end, "[G]o [B]uild")

					-- Go to alternate file (test/main)
					map("<leader>ga", function()
						local current_file = vim.fn.expand("%:p")
						if string.find(current_file, "_test.go") then
							local main_file = string.gsub(current_file, "_test.go", ".go")
							if vim.fn.filereadable(main_file) == 1 then
								vim.cmd("edit " .. main_file)
							end
						else
							local test_file = string.gsub(current_file, "%.go$", "_test.go")
							if vim.fn.filereadable(test_file) == 1 then
								vim.cmd("edit " .. test_file)
							else
								vim.notify("No test file found", vim.log.levels.WARN)
							end
						end
					end, "[G]o [A]lternate file")
				end

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				-- See `:help CursorHold` for information about when this is executed
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- LSP servers and clients are able to communicate to each other what features they support.
		-- By default, Neovim doesn't support everything that is in the LSP specification.
		-- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
		-- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Enable the following language servers
		--
		-- Add any additional override configuration in the following tables. Available keys are:
		-- - cmd (table): Override the default command used to start the server
		-- - filetypes (table): Override the default list of associated filetypes for the server
		-- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		-- - settings (table): Override the default settings passed when initializing the server.
		local servers = {
			-- Go Language Server
			gopls = {
				cmd = { "gopls", "serve" },
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
							shadow = true,
						},
						staticcheck = true,
						gofumpt = true,
						completeUnimported = true,
						usePlaceholders = true,
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
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
			sqlls = {},
			terraformls = {},
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

		-- Ensure the servers and tools above are installed
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format Lua code
			"prettier", -- ts/js formatter
			"eslint_d", -- ts/js linter
			"shfmt", -- Shell formatter
			"clang-format", -- C/C++ formatter
			"gofumpt", -- Go formatter
			"goimports", -- Go imports organizer
			"golangci-lint", -- Go linter
			"delve", -- Go debugger
			"gomodifytags", -- Go tags modifier
			"impl", -- Go interface implementation
			"gopls", -- Go language server
		})

		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
			auto_update = true,
		})

		for server, cfg in pairs(servers) do
			-- For each LSP server (cfg), we merge:
			-- 1. A fresh empty table (to avoid mutating capabilities globally)
			-- 2. Your capabilities object with Neovim + cmp features
			-- 3. Any server-specific cfg.capabilities if defined in `servers`
			cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})

			vim.lsp.config(server, cfg)
			vim.lsp.enable(server)
		end

		-- Setup Go debugger
		require("dap-go").setup()
	end,
}
