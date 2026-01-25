return {
	{
		"yamatsum/nvim-cursorline",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			vim.opt.cursorline = true

			-- Set the highlight colors
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3a3f4b" })

			-- Optional: Change color in insert mode
			local group = vim.api.nvim_create_augroup("CursorLineGroup", { clear = true })

			vim.api.nvim_create_autocmd("InsertEnter", {
				group = group,
				callback = function()
					vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3a3f4b", underline = false })
				end,
			})

			vim.api.nvim_create_autocmd("InsertLeave", {
				group = group,
				callback = function()
					vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3a3f4b", underline = false })
				end,
			})
		end,
	},
}
