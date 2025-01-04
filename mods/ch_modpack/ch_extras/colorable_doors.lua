-- doors:colorable
---------------------------------------------------------------

doors.register("door_colorable", {
	tiles = {{name = "ch_extras_cdoor_texture.png", backface_culling = true}},
	use_texture_alpha = "clip",
	description = "lakované dveře",
	inventory_image = "ch_extras_cdoor_item.png",
	groups = {choppy = 2, flammable = 2, oddly_breakable_by_hand = 2, ud_param2_colorable = 1},

	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_color4dir.png",
	overlay_tiles = {{name = "ch_extras_cdoor_overlay.png", color = "white", backface_culling = true}},

	recipe = {
		{"ch_extras:colorable_plastic", "", ""},
		{"ch_extras:colorable_plastic", "", ""},
		{"ch_extras:colorable_plastic", "", ""},
	},
})
