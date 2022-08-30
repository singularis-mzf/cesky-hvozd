
local S = technic.getter


minetest.register_node("technic:warning_block", {
	description = S("Warning Block"),
	tiles = {"technic_hv_cable.png"},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	sounds = default.node_sound_wood_defaults(),
})
