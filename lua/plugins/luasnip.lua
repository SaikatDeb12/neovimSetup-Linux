return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp", -- Optional
		config = function()
			require("luasnip.loaders.from_lua").lazy_load({
				paths = "/home/remotestate/.config/nvim/lua/snippets/",
			})
		end,
	},
}
