local active_border_color = "rgba(cdd6f4cc)"
local inactive_border_color = "rgba(585b70aa)"

hl.config({
	general = {
		gaps_in = 20,
		gaps_out = 20,
		col = {
			active_border = active_border_color,
			inactive_border = inactive_border_color,
		},
	},

	decoration = {
		rounding = 20,
	},

	group = {
		col = {
			border_active = active_border_color,
			border_inactive = inactive_border_color,
		},
	},
})
