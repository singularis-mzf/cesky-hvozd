-- local S = minetest.get_translator("ch_extras")
-- stone Ladder (taken from Ethereal NG mod)
minetest.register_node(":ethereal:stone_ladder", {
	description = "kamenný žebřík",
	drawtype = "signlike",
	tiles = {"ethereal_stone_ladder.png"},
	inventory_image = "ethereal_stone_ladder.png",
	wield_image = "ethereal_stone_ladder.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted"
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1},
	legacy_wallmounted = true,
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "ethereal:stone_ladder 4",
	recipe = {
		{"group:stone", "", "group:stone"},
		{"group:stone", "group:stone", "group:stone"},
		{"group:stone", "", "group:stone"}
	}
})

-- Paper Wall (taken from Ethereal NG mod)
minetest.register_node(":ethereal:paper_wall", {
	drawtype = "nodebox",
	description = "papírová stěna",
	tiles = {"ethereal_paper_wall.png"},
	inventory_image = "ethereal_paper_wall.png",
	wield_image = "ethereal_paper_wall.png",
	paramtype = "light",
	groups = {snappy = 3},
	sounds = default.node_sound_wood_defaults(),
	walkable = true,
	is_ground_content = false,
	sunlight_propagates = true,
	paramtype2 = "facedir",
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 5/11, 0.5, 0.5, 8/16}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 5/11, 0.5, 0.5, 8/16}
		}
	}
})

minetest.register_craft({
	output = "ethereal:paper_wall",
	recipe = {
		{"group:stick", "default:paper", "group:stick"},
		{"group:stick", "default:paper", "group:stick"},
		{"group:stick", "default:paper", "group:stick"}
	}
})

-- Sakura Doors (taken from Ethereal NG mod)
doors.register_door("ethereal:door_sakura", {
	tiles = {
		{name = "ethereal_sakura_door.png", backface_culling = true}
	},
	description = "dveře s papírovou výplní",
	inventory_image = "ethereal_sakura_door_inv.png",
	groups = {
		snappy = 1, choppy = 2, oddly_breakable_by_hand = 2,
		flammable = 2
	},
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	recipe = {
		{"group:wood",  "default:paper"},
		{"default:paper",  "group:wood"},
		{"group:wood", "default:paper"}
	}
})

minetest.register_craft({
	output = "ethereal:door_sakura",
	recipe = {
		{"default:paper",  "group:wood"},
		{"group:wood",  "default:paper"},
		{"default:paper",  "group:wood"},
	},
})
