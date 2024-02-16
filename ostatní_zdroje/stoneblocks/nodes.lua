local S = stoneblocks.S
local sound_api = stoneblocks.soundApi

minetest.register_node("stoneblocks:black_granite_block", {
	description = S("Black granite stone"),
	tiles = { "stoneblocks_black_granite_block.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:grey_granite", {
	description = S("Grey granite stone"),
	tiles = { "stoneblocks_stone_grey_granite.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2, },
})

minetest.register_node("stoneblocks:rubyblock_with_emerald", {
	description = S("Rubyblock with emerald"),
	tiles = { "stoneblocks_rubyblock_with_emerald.png" },
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX, -- This node emits light
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 3,  },
})

minetest.register_node("stoneblocks:rubyblock", {
	description = S("Rubyblock"),
	tiles = { "stoneblocks_rubyblock.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 1,  },
})

minetest.register_node("stoneblocks:cats_eye", {
	description = S("Cats eye"),
	tiles = { "stoneblocks_cats_eye.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:stone_with_ruby", {
	description = S("Stone with ruby"),
	tiles = { "stoneblocks_stone_with_ruby.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:stone_with_emerald", {
	description = S("Stone with emerald"),
	tiles = { "stoneblocks_stone_with_emerald.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:emeraldblock_with_ruby", {
	description = S("Emeraldblock with ruby"),
	tiles = { "stoneblocks_emeraldblock_with_ruby.png" },
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:granite_block", {
	description = S("Granite stone"),
	tiles = { "stoneblocks_granite_block.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 1,  },
})

minetest.register_node("stoneblocks:red_granite_block", {
	description = S("Red granite stone"),
	tiles = { "stoneblocks_red_granite_block.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:rose_granite_block", {
	description = S("Rose granite stone"),
	tiles = { "stoneblocks_rose_granite_block.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:stone_with_turquoise_glass", {
	description = S("Stone with turquoise glass"),
	tiles = { "stoneblocks_stone_with_turquoise_glass.png" },
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 1,  oddly_breakable_by_hand = 2, },
})

minetest.register_node("stoneblocks:emeraldblock", {
	description = S("Emerald block"),
	tiles = { "stoneblocks_emeraldblock.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 1,  },
})

minetest.register_node("stoneblocks:mixed_stone_block", {
	description = S("Mixed stone block"),
	tiles = { "stoneblocks_mixed_stone_block.png" },
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX, 
	sounds = sound_api.node_sound_stone_defaults(),
	glasslike = 1, -- glasslike_framed
	groups = { stone = 1, cracky = 1,  },
})

minetest.register_node("stoneblocks:stone_with_turquoise", {
	description = S("Stone with turquoise"),
	tiles = { "stoneblocks_stone_with_turquoise.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 3,  },
})

minetest.register_node("stoneblocks:sapphire_block", {
	description = S("Sapphire stone"),
	tiles = { "stoneblocks_sapphire_block.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 1,  },
})

minetest.register_node("stoneblocks:stone_with_sapphire", {
	description = S("Stone with sapphire"),
	tiles = { "stoneblocks_stone_with_sapphire.png" },
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 3,  },
})

minetest.register_node("stoneblocks:turquoise_block", {
	description = S("Turquoise stone"),
	tiles = { "stoneblocks_turquoise_block.png" },
	drawtype = "glasslike",
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2,  },
})

minetest.register_node("stoneblocks:red_granite_turquoise_block", {
	description = S("Red turquoise stone"),
	tiles = { "stoneblocks_red_granite_turquoise_block.png" },
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX, -- This node emits light
	sounds = sound_api.node_sound_stone_defaults(),
	groups = { stone = 1, cracky = 2, },
})

minetest.register_node("stoneblocks:turquoise_glass", {
	description = S("Turquoise glass stone"),
	tiles = { "stoneblocks_turquoise_glass_block.png" },
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX, -- This node emits light
	sounds = sound_api.node_sound_stone_defaults(),
	glasslike = 1, -- glasslike_framed
	groups = { stone = 1, cracky = 2,  oddly_breakable_by_hand = 2, },
})
