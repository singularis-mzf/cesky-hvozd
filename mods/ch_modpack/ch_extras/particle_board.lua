-- ch_extras:particle_board (dřevotříska)
---------------------------------------------------------------
local def = {
	description = "dřevotříska",
	tiles = {"ch_extras_particle_board.png"},
	drawtype = "normal",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 3, ud_param2_colorable = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
}
local def2 = table.copy(def)
def2.paramtype2 = "colorfacedir"
def2.palette = "unifieddyes_palette_greys.png"
-- def2.airbrush_replacement_node = "ch_extras:particle_board_grey"
def2.groups = ch_core.assembly_groups(def.groups, {ud_param2_colorable = 0, not_in_creative_inventory = 1})
def2.on_dig = unifieddyes.on_dig

unifieddyes.generate_split_palette_nodes("ch_extras:particle_board", def2)
minetest.register_alias("ch_extras:particle_board", "ch_extras:particle_board_grey")
minetest.override_item("ch_extras:particle_board_grey", {groups = def.groups})
stairsplus:register_all("ch_extras", "particle_board", "ch_extras:particle_board_grey", def)

minetest.register_craft({
	output = "ch_extras:particle_board 4",
	recipe = {
		{"technic:common_tree_grindings", "technic:common_tree_grindings", "technic:common_tree_grindings"},
		{"technic:common_tree_grindings", "mesecons_materials:glue", "technic:common_tree_grindings"},
		{"technic:common_tree_grindings", "technic:common_tree_grindings", "technic:common_tree_grindings"},
	}
})

minetest.register_craft({
	output = "ch_extras:particle_board 4",
	recipe = {
		{"technic:rubber_tree_grindings", "technic:rubber_tree_grindings", "technic:rubber_tree_grindings"},
		{"technic:rubber_tree_grindings", "mesecons_materials:glue", "technic:rubber_tree_grindings"},
		{"technic:rubber_tree_grindings", "technic:rubber_tree_grindings", "technic:rubber_tree_grindings"},
	}
})
