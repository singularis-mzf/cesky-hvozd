print("Craftable Lava is Enabled")


minetest.register_node("craftable_lava:hot_stone", {
    description = "Hot Stone",
	tiles = {"default_stone.png^craftable_lava_hot_stone.png"},
    --[[tiles = {
	    {
	    name = "craftable_lava_hot_stone_animation.png",
		    animation = {
			    type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
		    },
	    },
	},]]--
	groups = {cracky = 2},
	sounds = default.node_sound_stone_defaults(),
  light_source = 4,
})

minetest.register_craft({
    type = "cooking",
    output = "craftable_lava:hot_stone",
    recipe = "default:stone",
	cooktime = 7,
})

minetest.register_craft({
    output = "bucket:bucket_lava",
	recipe = {{"craftable_lava:hot_stone", "craftable_lava:hot_stone", "craftable_lava:hot_stone"},
    {"craftable_lava:hot_stone", "bucket:bucket_empty", "craftable_lava:hot_stone"},
    {"craftable_lava:hot_stone", "craftable_lava:hot_stone", "craftable_lava:hot_stone"}},
})
