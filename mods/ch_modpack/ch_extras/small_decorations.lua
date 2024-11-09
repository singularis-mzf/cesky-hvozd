local def, nbox

-- ch_extras:cracks
---------------------------------------------------------------
nbox = {
	type = "fixed",
	fixed = {-0.4, -0.5, -0.4, 0.4, -7/16, 0.4},
}
def = {
	description = "praskliny (jen vodorovně)",
	drawtype = "mesh",
	mesh = "ch_extras_cracks.obj",
	selection_box = nbox,
	--[[
	-- top, bottom, right, left, back, front
	tiles = {"ch_extras_praskliny.png",
             "ch_extras_praskliny.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             }, ]]
	tiles = {"ch_extras_praskliny.png^[opacity:192"},
	use_texture_alpha = "blend",
	inventory_image = "ch_core_white_pixel.png^[invert:rgb^ch_extras_praskliny.png",
	wield_image = "ch_extras_praskliny.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	buildable_to = true,
	floodable = true,
	walkable = false,
	after_place_node = ch_extras.degrotate_after_place_node,
	on_rotate = ch_extras.degrotate_on_rotate,
}

minetest.register_node("ch_extras:cracks", def)
minetest.register_craft({
	output = "ch_extras:cracks 16",
	recipe = {
		{"", "default:cobble"},
		{"default:cobble", ""},
	},
})

-- ch_extras:spina
---------------------------------------------------------------

nbox = {
	type = "fixed",
	fixed = {-0.1, -0.5, -0.1, 0.1, -7/16, 0.1},
}
def = {
	description = "špína (jen vodorovně)",
	drawtype = "mesh",
	mesh = "ch_extras_cracks.obj",
	selection_box = nbox,
	tiles = {"ch_extras_spina.png"},
	use_texture_alpha = "blend",
	inventory_image = "ch_core_white_pixel.png^[multiply:#cccccc^ch_extras_spina.png^ch_extras_spina.png",
	wield_image = "ch_extras_spina.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	buildable_to = true,
	floodable = true,
	walkable = false,
	after_place_node = ch_extras.degrotate_after_place_node,
	on_rotate = ch_extras.degrotate_on_rotate,
}

minetest.register_node("ch_extras:spina", def)
minetest.register_craft({
	output = "ch_extras:spina 16",
	recipe = {{"darkage:silt_lump"}},
})

minetest.register_craft({
	output = "ch_extras:spina 64",
	recipe = {{"default:dirt", ""}, {"default:sand", ""}},
})
