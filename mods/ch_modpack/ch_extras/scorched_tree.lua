-- Scorched tree:
local def = {
	description = "ohořelý kmen",
	tiles = {
		{name = "ch_extras_scorched_tree_top.png", backface_culling = true},
		{name = "ch_extras_scorched_tree_top.png", backface_culling = true},
		{name = "ch_extras_scorched_tree.png", backface_culling = true},
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, tree = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node,
}
minetest.register_node("ch_extras:scorched_tree", def)

minetest.register_craft{
	output = "ch_extras:scorched_tree",
	recipe = {
		{"group:tree", ""},
		{"default:torch", ""},
	},
}

minetest.register_craft{
	type = "fuel",
	recipe = "ch_extras:scorched_tree",
	burntime = 30,
}

def = {
	description = "plot z ohořelého kmene",
	texture = "ch_extras_scorched_tree.png",
	material = "ch_extras:scorched_tree",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
}
default.register_fence("ch_extras:scorched_tree_fence", table.copy(def))
def.description = "zábradlí z ohořelého kmene"
default.register_fence_rail("ch_extras:scorched_tree_fence_rail", table.copy(def))
def.description = "branka z ohořelého kmene"
doors.register_fencegate("ch_extras:scorched_tree_fence_gate", def)
default.register_mesepost("ch_extras:scorched_tree_mese_post_light", {
	description = "ohořelý sloupek s meseovým světlem",
	texture = "ch_extras_scorched_tree.png",
	material = "ch_extras:scorched_tree",
})

stairsplus:register_all("ch_extras", "scorched_tree", "ch_extras:scorched_tree", {
	description = "ohořelý kmen",
	tiles = {"ch_extras_scorched_tree.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
})
stairsplus:register_noface_trunk("ch_extras", "scorched_tree_noface", "ch_extras:scorched_tree")
stairsplus:register_allfaces_trunk("ch_extras", "scorched_tree_allfaces", "ch_extras:scorched_tree")
