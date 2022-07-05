local def = {
	description = "Vlajka České republiky",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.333333, 7/16, 0.5, 0.333333, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.333333, 7/16, 0.5, 0.333333, 0.5}
	},
	-- top, bottom, right, left, back, front
	tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_core_cz_flag.png",
             "ch_core_white_pixel.png^[multiply:#11457e",
             "ch_core_cz_flag.png^[transformFX",
             "ch_core_cz_flag.png",},
	inventory_image = "ch_core_cz_flag_inv.png",
	wield_image = "ch_core_cz_flag_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_wood_defaults(),
}

minetest.register_node("ch_core:czech_flag", def)

def = table.copy(def)
def.description = "Vlajka Slovenska"
def.tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_core_sk_flag.png",
             "ch_core_sk_flag.png",
             "ch_core_sk_flag.png^[transformFX",
             "ch_core_sk_flag.png",}
def.inventory_image = "ch_core_sk_flag_inv.png"
def.wield_image = "ch_core_sk_flag_inv.png"
minetest.register_node("ch_core:slovak_flag", def)

minetest.register_craft({
	output = "ch_core:czech_flag",
	recipe = {
		{"", "dye:white", ""},
		{"dye:blue", "", ""},
		{"", "dye:red", ""},
	},
})

minetest.register_craft({
	output = "ch_core:slovak_flag",
	recipe = {
		{"dye:white", "", ""},
		{"", "dye:blue", ""},
		{"dye:red", "", ""},
	},
})
