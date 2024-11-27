ch_base.open_mod(minetest.get_current_modname())

local S = minetest.get_translator("homedecor_wardrobe")
local modpath = minetest.get_modpath("homedecor_wardrobe")

homedecor.register("wardrobe", {
	description = S("Wardrobe"),
	mesh = "homedecor_bedroom_wardrobe.obj",
	tiles = {
		{name = "homedecor_generic_wood_plain.png", color = 0xffa76820},
		"homedecor_wardrobe_drawers.png",
		"homedecor_wardrobe_doors.png"
	},
	inventory_image = "homedecor_wardrobe_inv.png",
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
	selection_box = homedecor.nodebox.slab_y(2),
	collision_box = homedecor.nodebox.slab_y(2),
	expand = { top="placeholder" },
	infotext=S("Wardrobe"),
	inventory = {
		size=50,
		lockable=true,
	},
	on_rotate = minetest.get_modpath("screwdriver") and screwdriver.rotate_simple or nil,
})

minetest.register_craft( {
	output = "homedecor:wardrobe",
	recipe = {
		{ "homedecor:drawer_small", "homedecor:kitchen_cabinet_colorable" },
		{ "homedecor:drawer_small", "group:wood" },
		{ "homedecor:drawer_small", "group:wood" }
	},
})

ch_base.close_mod(minetest.get_current_modname())
