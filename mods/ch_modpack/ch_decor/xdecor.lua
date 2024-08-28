local S = minetest.get_translator("ch_decor")
local has_moreblocks = minetest.get_modpath("moreblocks")
local has_unifieddyes = minetest.get_modpath("unifieddyes")
local def

def = {
	description = "linoleum",
	drawtype = "normal",
	tiles = {"xdecor_wood_tile.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
}

minetest.register_node(":xdecor:wood_tile", table.copy(def))
if has_moreblocks then
	stairsplus:register_all("xdecor", "wood_tile", "xdecor:wood_tile", table.copy(def))
end

minetest.register_craft{
	output = "xdecor:wood_tile 9",
	recipe = {
		{"farming:flax_seed_oil", "farming:flax_seed_oil", "farming:flax_seed_oil"},
		{"", "default:pine_wood", ""},
		{"", "", ""},
	},
}

if has_unifieddyes then
	def = {
		description = "barvitelné linoleum",
		drawtype = "normal",
		tiles = {"ch_decor_colorable_wood_tile.png"},
		is_ground_content = false,
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		groups = {cracky = 3, ud_param2_colorable = 1},
		sounds = default.node_sound_stone_defaults(),
		on_construct = unifieddyes.on_construct,
		on_dig = unifieddyes.on_dig,
	}
	minetest.register_node("ch_decor:wood_tile", def)
end
