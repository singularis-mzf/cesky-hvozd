local S = ...

closet.register_container("closet", {
	description = S("Closet"),
	inventory_image = "closet_closet_inv.png",
	mesh = "closet.obj",
	tiles = {
		"closet_closet.png",
	},
	use_texture_alpha = true,
	selection_box = {
		type = "fixed",
		fixed = { -1/2, -1/2, 0.062500, 1/2, 1.5, 1/2 },
	},
	sounds = default.node_sound_wood_defaults(),
	sound_open = "default_chest_open",
	sound_close = "default_chest_close",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
})

minetest.register_craft({
	output = "closet:closet",
	type = "shaped",
		recipe = {
		{"", "group:wood", "group:wood"},
		{"", "group:wood", "group:mirror"},
		{"", "group:wood", "group:wood"},
	}
})
