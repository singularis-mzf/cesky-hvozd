local def

-- ch_core:czech_flag
---------------------------------------------------------------
def = {
	description = "vlajka České republiky",
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
             "ch_extras_cz_flag.png",
             "ch_core_white_pixel.png^[multiply:#11457e",
             "ch_extras_cz_flag.png^[transformFX",
             "ch_extras_cz_flag.png",},
	inventory_image = "ch_extras_cz_flag_inv.png",
	wield_image = "ch_extras_cz_flag_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_wood_defaults(),
}

minetest.register_node("ch_extras:czech_flag", def)
minetest.register_craft({
	output = "ch_extras:czech_flag",
	recipe = {
		{"", "dye:white", ""},
		{"dye:blue", "", ""},
		{"", "dye:red", ""},
	},
})
minetest.register_alias("ch_core:czech_flag", "ch_extras:czech_flag")

-- ch_core.slovak_flag
---------------------------------------------------------------
def = table.copy(def)
def.description = "vlajka Slovenska"
def.tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_extras_sk_flag.png",
             "ch_extras_sk_flag.png",
             "ch_extras_sk_flag.png^[transformFX",
             "ch_extras_sk_flag.png",}
def.inventory_image = "ch_extras_sk_flag_inv.png"
def.wield_image = "ch_extras_sk_flag_inv.png"

minetest.register_node("ch_extras:slovak_flag", def)
minetest.register_craft({
	output = "ch_extras:slovak_flag",
	recipe = {
		{"dye:white", "", ""},
		{"", "dye:blue", ""},
		{"dye:red", "", ""},
	},
})
minetest.register_alias("ch_core:slovak_flag", "ch_extras:slovak_flag")

-- ch_extras.railway_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "železniční štěrk"
def.tiles = {
	"default_gravel.png^[multiply:#956338"
}
def.drop = nil
minetest.register_node("ch_extras:railway_gravel", def)

minetest.register_craft({
	output = "ch_extras:railway_gravel 2",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:iron_lump"},
})

minetest.register_craft({
	output = "ch_extras:railway_gravel",
	type = "shapeless",
	recipe = {"default:gravel", "technic:wrought_iron_dust"},
})
minetest.register_alias("ch_core:railway_gravel", "ch_extras:railway_gravel")

stairsplus:register_slabs_and_slopes("ch_extras", "railway_gravel", "ch_extras:railway_gravel", minetest.registered_nodes["ch_extras:railway_gravel"])
stairsplus:register_alias_all("ch_core", "railway_gravel", "ch_extras", "railway_gravel")

--[[ PLAKÁTY
local box = {
		type = "fixed",
		-- fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 8/16}
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
}
def = {
	description = "plakát 1: levý díl",
	drawtype = "normal",
	-- node_box = box,
	-- selection_box = box,
	tiles = {"ch_core_plakat_yf1.png"},
	inventory_image = "ch_core_plakat_yf1.png",
	wield_image = "ch_core_plakat_yf1.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_leaves_defaults(),
}

minetest.register_node("ch_core:plakat_yf_left", table.copy(def))
def.description = "plakát 1: pravý díl"
def.tiles = {"ch_core_plakat_yf2.png"}
def.inventory_image = "ch_core_plakat_yf2.png"
def.weild_image = "ch_core_plakat_yf2.png"
minetest.register_node("ch_core:plakat_yf_right", table.copy(def))
]]


