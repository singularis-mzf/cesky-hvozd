local S = minetest.get_translator("ch_decor")
local def

def = {
	description = "linoleum",
	drawtype = "normal",
	tiles = {"[combine:32x32:0,0=xdecor_wood_tile.png:16,0=xdecor_wood_tile.png:0,16=xdecor_wood_tile.png:16,16=xdecor_wood_tile.png"},
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
}

minetest.register_node(":xdecor:wood_tile", table.copy(def))
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("xdecor", "wood_tile", "xdecor:wood_tile", table.copy(def))
end
