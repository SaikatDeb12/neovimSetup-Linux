return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		-- Shortcuts
		local map = vim.keymap.set

		-- Add current file
		map("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon Add File" })

		-- Toggle quick menu
		map("n", "<leader>o", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon Quick Menu" })

		-- FAST switching between marked files
		map("n", "<leader>1", function()
			harpoon:list():select(1)
		end)
		map("n", "<leader>2", function()
			harpoon:list():select(2)
		end)
		map("n", "<leader>3", function()
			harpoon:list():select(3)
		end)
		map("n", "<leader>4", function()
			harpoon:list():select(4)
		end)

		-- TRUE toggle between 2 files
		local last = 1
		map("n", "<leader><Tab>", function()
			if last == 1 then
				harpoon:list():select(2)
				last = 2
			else
				harpoon:list():select(1)
				last = 1
			end
		end, { desc = "Toggle between file 1 and 2" })
	end,
}
