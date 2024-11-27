ch_base.open_mod(minetest.get_current_modname())
-- Nature Classic mod
-- Originally by neko259

local S = minetest.get_translator("nature_classic")


minetest.register_node(":nature:blossom", {
    description = S("Apple blossoms"),
    drawtype = "allfaces_optional",
    tiles = { "default_leaves.png^nature_blossom.png" },
    paramtype = "light",
    groups = { snappy = 3, leafdecay = 1, leaves = 1, flammable = 2 },
    sounds = default.node_sound_leaves_defaults(),
	waving = 1
})

default.register_leafdecay({
	trunks = { "default:tree" },
	leaves = { "nature:blossom", "default:leaves" },
	radius = 2,
})

minetest.register_craft({
    type = "fuel",
    recipe = "nature:blossom",
    burntime = 2,
})

ch_base.close_mod(minetest.get_current_modname())
