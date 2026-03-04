return {
	"leath-dub/snipe.nvim",
	keys = {
		{
			"<leader>sp",
			function()
				require("snipe").open_buffer_menu()
			end,
			desc = "Snipe buffer menu",
		},
	},
	opts = {
		ui = {
			position = "center",
		},
		format = function(buf)
			return vim.fn.fnamemodify(buf.name, ":t")
		end,
		navigate = {
			next = "j",
			prev = "k",
			close_buffer = "d",
			open_split = "s",
			open_vsplit = "v",
		},
	},
}
