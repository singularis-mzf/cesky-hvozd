local S = minetest.get_translator("ch_decor")
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
if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("xdecor", "wood_tile", "xdecor:wood_tile", table.copy(def))
end
