ch_core.open_submod("sickles")
local sickle_sounds = {breaks = "default_tool_breaks"}
local sickle_groups = {sickle = 1}

minetest.register_tool("ch_core:sickle_wood", {
	description = "Dřevěný srp",
	inventory_image = "ch_core_sickle_wood.png",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {2.5, 1.2, 0.5}, uses = 10, maxlevel = 1},
		},
	},
	sound = sickle_sounds,
	groups = sickle_groups,
})
minetest.register_tool("ch_core:sickle_stone", {
	description = "Kamenný srp",
	inventory_image = "ch_core_sickle_stone.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {2.5, 1.1, 0.4}, uses = 10, maxlevel = 3},
		},
	},
	sound = sickle_sounds,
	groups = sickle_groups,
})
minetest.register_tool("ch_core:sickle_steel", {
	description = "Železný srp",
	inventory_image = "ch_core_sickle_steel.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {2.0, 1.0, 0.3}, uses = 40, maxlevel = 3},
		},
	},
	sound = sickle_sounds,
	groups = sickle_groups,
})
minetest.register_tool("ch_core:sickle_mese", {
	description = "Meseový srp",
	inventory_image = "ch_core_sickle_mese.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {1.0, 0.4, 0.2}, uses = 60, maxlevel = 3},
		},
	},
	sound = sickle_sounds,
	groups = sickle_groups,
})

minetest.register_craft({
	output = "ch_core:sickle_wood",
	recipe = {
		{"group:wood", ""},
		{"", "group:wood"},
		{"group:stick", ""}
	}
})

minetest.register_craft({
	output = "ch_core:sickle_stone",
	recipe = {
		{"group:stone", ""},
		{"", "group:stone"},
		{"group:stick", ""}
	}
})

minetest.register_craft({
	output = "ch_core:sickle_steel",
	recipe = {
		{"default:steel_ingot", ""},
		{"", "default:steel_ingot"},
		{"group:stick", ""}
	}
})

minetest.register_craft({
	output = "ch_core:sickle_mese",
	recipe = {
		{"default:mese_crystal", ""},
		{"", "default:mese_crystal"},
		{"group:stick", ""}
	}
})

ch_core.close_submod("sickles")
