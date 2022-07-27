print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

minetest.register_node("craftable_lava:hot_stone", {
    description = "Vřelá skála",
	tiles = {"default_stone.png^craftable_lava_hot_stone.png"},
    tiles = {
	    {
	    name = "craftable_lava_hot_stone_animation.png",
		    animation = {
			    type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
		    },
	    },
	},--]]--
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

minetest.register_craft({
    output = "default:stone",
	recipe = {{"craftable_lava:hot_stone"}},
})

minetest.register_ore({
	ore_type = "sheet",
	ore = "craftable_lava:hot_stone",
	wherein = "default:stone",
	y_min = -31000,
	y_max = -256,
	column_height_min = 1,
	column_height_max = 6,
	noise_threshold = 0.35,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = {x = 100, y = 100, z = 100},
		seed = 1431,
		octaves = 1,
		persist = 0.6
	}
})
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
