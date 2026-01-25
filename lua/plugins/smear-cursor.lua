return {
	"sphamba/smear-cursor.nvim",
	opts = {
		smear_between_buffers = true,
		smear_between_neighbor_lines = true,
		smear_insert_mode = true,
		time_interval = 7, -- lower = faster animation
		damping = 0.65, -- lower = more bouncy
	},
}
