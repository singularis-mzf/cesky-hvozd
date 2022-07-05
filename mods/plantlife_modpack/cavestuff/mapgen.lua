--Map Generation Stuff

minetest.register_decoration({
	deco_type = "simple",
	place_on = { "default:dirt_with_grass", "default:dirt", "default:gravel", "default:stone", "default:permafrost_with_stones" },
	sidelen = 16,
	fill_ratio = 0.0025,
	y_min = -31000,
	y_max = 31000,
	flags = "",
	decoration = "cavestuff:pebble_1",
	height = 1,
	height_max = 0,
	param2 = 0,
	param2_max = 3,
});

minetest.register_decoration({
	deco_type = "simple",
	place_on = { "default:dirt_with_grass", "default:dirt", "default:gravel", "default:stone", "default:permafrost_with_stones", "default:sand", "default:silver_sand" },
	sidelen = 16,
	fill_ratio = 0.0025,
	y_min = -31000,
	y_max = 31000,
	flags = "",
	decoration = "cavestuff:pebble_2",
	height = 1,
	height_max = 0,
	param2 = 0,
	param2_max = 3,
});

minetest.register_decoration({
	deco_type = "simple",
	place_on = { "default:desert_sand", "default:desert_stone" },
	sidelen = 16,
	fill_ratio = 0.0025,
	y_min = -31000,
	y_max = 31000,
	flags = "",
	decoration = "cavestuff:desert_pebble_1",
	height = 1,
	height_max = 0,
	param2 = 0,
	param2_max = 3,
});


minetest.register_decoration({
	deco_type = "simple",
	place_on = { "default:desert_sand", "default:desert_stone" },
	sidelen = 16,
	fill_ratio = 0.0025,
	y_min = -31000,
	y_max = 31000,
	flags = "",
	decoration = "cavestuff:desert_pebble_2",
	height = 1,
	height_max = 0,
	param2 = 0,
	param2_max = 3,
});
