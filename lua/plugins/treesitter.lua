return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		-- Go-specific treesitter modules
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	main = "nvim-treesitter.configs", -- Sets main module to use for opts
	-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
	opts = {
		ensure_installed = {
			"go",
			"gomod",
			"gosum",
			"gowork",
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
			"yaml",
			"bash",
			"markdown",
			"markdown_inline",
			"html",
			"css",
			"cpp",
			"make",
			"cmake",
		},
		-- Autoinstall languages that are not installed
		auto_install = true,
		highlight = {
			enable = true,
			-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
			--  If you are experiencing weird indenting issues, add the language to
			--  the list of additional_vim_regex_highlighting and disabled languages for indent.
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
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
					["ap"] = "@parameter.outer",
					["ip"] = "@parameter.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
		},
	},
}
