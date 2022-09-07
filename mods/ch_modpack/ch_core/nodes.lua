ch_core.open_submod("nodes")

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
minetest.register_craft({
	output = "ch_core:czech_flag",
	recipe = {
		{"", "dye:white", ""},
		{"dye:blue", "", ""},
		{"", "dye:red", ""},
	},
})

-- ch_core.slovak_flag
---------------------------------------------------------------
def = table.copy(def)
def.description = "vlajka Slovenska"
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
	output = "ch_core:slovak_flag",
	recipe = {
		{"dye:white", "", ""},
		{"", "dye:blue", ""},
		{"dye:red", "", ""},
	},
})

-- ch_core.railway_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "železniční štěrk"
def.tiles = {
	"default_gravel.png^[multiply:#956338"
}
def.drop = nil
minetest.register_node("ch_core:railway_gravel", def)

minetest.register_craft({
	output = "ch_core:railway_gravel 2",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:iron_lump"},
})

minetest.register_craft({
	output = "ch_core:railway_gravel",
	type = "shapeless",
	recipe = {"default:gravel", "technic:wrought_iron_dust"},
})

-- ch_core.light_{0..15}
---------------------------------------------------------------
local box = {
	type = "fixed",
	fixed = {-1/16, -8/16, -1/16, 1/16, -7/16, 1/16}
}
def = {
	description = "0",
	drawtype = "nodebox",
	node_box = box,
	selection_box = box,
	-- top, bottom, right, left, back, front
	tiles = {"ch_core_white_pixel.png^[opacity:0"},
	use_texture_alpha = "clip",
	inventory_image = "default_invisible_node_overlay.png",
	wield_image = "default_invisible_node_overlay.png",
	paramtype = "light",
	paramtype2 = "none",
	light_source = 0,

	sunlight_propagates = true,
	walkable = false,
	pointable = true,
	buildable_to = true,
	floodable = true,
	drop = ""
}

for i = 0, minetest.LIGHT_MAX do
	local name = "light_"
	if i < 10 then
		name = name.."0"
	end
	name = name..i
	def.description = "administrátorské světlo "..i
	if i > 0 then
		def.groups = {ch_core_light = i}
		def.light_source = i
	end
	minetest.register_node("ch_core:"..name, table.copy(def))
	if i > 0 and minetest.get_modpath("wielded_light") then
		wielded_light.register_item_light("ch_core:"..name, i, false)
	end
end
minetest.register_alias("ch_core:light_max", "ch_core:light_"..minetest.LIGHT_MAX)

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

ch_core.close_submod("nodes")
