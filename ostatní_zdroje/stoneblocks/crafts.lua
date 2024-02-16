minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:sapphire_block",
	recipe = {
		{ "",                                "stoneblocks:stone_with_sapphire", "" },
		{ "stoneblocks:stone_with_sapphire", "stoneblocks:stone_with_sapphire", "stoneblocks:stone_with_sapphire" },
		{ "",                                "stoneblocks:stone_with_sapphire", "" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:stone_lantern_yellow",
	recipe = {
		{ "",                            "stoneblocks:stone_with_emerald", "" },
		{ "stoneblocks:stone_with_ruby", "stoneblocks:rubyblock",          "stoneblocks:stone_with_turquoise" },
		{ "default:glass",               "default:glass",                  "default:glass" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:stone_lantern_red",
	recipe = {
		{ "stoneblocks:rubyblock",       "stoneblocks:stone_with_emerald", "stoneblocks:rubyblock" },
		{ "stoneblocks:stone_with_ruby", "stoneblocks:rubyblock",          "stoneblocks:red_granite_block" },
		{ "default:glass",               "default:glass",                  "default:glass" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:stone_lantern_blue",
	recipe = {
		{ "",                           "stoneblocks:stone_with_sapphire", "" },
		{ "stoneblocks:sapphire_block", "stoneblocks:sapphire_block",      "stoneblocks:turquoise_glass" },
		{ "default:glass",              "default:glass",                   "default:glass" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:stone_lantern_green",
	recipe = {
		{ "",                         "stoneblocks:stone_with_emerald", "" },
		{ "stoneblocks:emeraldblock", "stoneblocks:emeraldblock",       "stoneblocks:turquoise_block" },
		{ "default:glass",            "default:glass",                  "default:glass" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:stone_lantern_red_green_yellow",
	recipe = {
		{ "stoneblocks:rubyblock",          "default:glass",            "stoneblocks:rubyblock" },
		{ "stoneblocks:stone_with_emerald", "stoneblocks:emeraldblock", "stoneblocks:stone_with_emerald" },
		{ "default:glass",                  "default:glass",            "default:glass" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:mixed_stone_block",
	recipe = {
		{ "stoneblocks:turquoise_glass", "stoneblocks:rubyblock",           "stoneblocks:emeraldblock" },
		{ "stoneblocks:sapphire_block",        "stoneblocks:cats_eye",            "stoneblocks:red_granite_block" },
		{ "stoneblocks:granite_block",         "stoneblocks:stone_with_sapphire", "stoneblocks:emeraldblock_with_ruby" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:rubyblock",
	recipe = {
		{ "",                            "stoneblocks:stone_with_ruby", "" },
		{ "stoneblocks:stone_with_ruby", "stoneblocks:stone_with_ruby", "stoneblocks:stone_with_ruby" },
		{ "",                            "stoneblocks:stone_with_ruby", "" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:sensitive_glass_block",
	recipe = {
		{ "stoneblocks:turquoise_glass",      "stoneblocks:stone_with_turquoise_glass", "stoneblocks:turquoise_glass" },
		{ "stoneblocks:stone_with_turquoise_glass", "default:glass",                          "stoneblocks:turquoise_glass" },
		{ "default:glass",                          "stoneblocks:stone_with_emerald",         "default:glass" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:emeraldblock",
	recipe = {
		{ "",                               "stoneblocks:stone_with_emerald", "" },
		{ "stoneblocks:stone_with_emerald", "stoneblocks:stone_with_emerald", "stoneblocks:stone_with_emerald" },
		{ "",                               "stoneblocks:stone_with_emerald", "" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:turquoise_glass",
	recipe = {
		{ "stoneblocks:stone_with_turquoise", "stoneblocks:stone_with_turquoise_glass", "" },
		{ "stoneblocks:stone_with_turquoise_glass", "stoneblocks:stone_with_turquoise_glass", "stoneblocks:stone_with_turquoise_glass" },
		{ "",                                       "stoneblocks:stone_with_turquoise_glass", "" }
	}
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:turquoise_block",
	recipe = {
		{ "",                                       "stoneblocks:stone_with_turquoise", "" },
		{ "stoneblocks:stone_with_turquoise", "stoneblocks:stone_with_turquoise", "stoneblocks:stone_with_turquoise" },
		{ "",                                       "stoneblocks:stone_with_turquoise", "" }
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "stoneblocks:rubyblock_with_emerald",
	recipe = { "stoneblocks:stone_with_ruby", "stoneblocks:stone_with_ruby", "stoneblocks:stone_with_emerald" }
})

minetest.register_craft({
	type = "shaped",
	output = "stoneblocks:cats_eye",
	recipe = {
		{ "stoneblocks:black_granite_block", "stoneblocks:rubyblock",          "stoneblocks:sapphire_block" },
		{ "",                                "stoneblocks:grey_granite", "" },
		{ "",                                "stoneblocks:emeraldblock",       "" }
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "stoneblocks:emeraldblock_with_ruby",
	recipe = { "stoneblocks:stone_with_emerald", "stoneblocks:stone_with_emerald", "stoneblocks:stone_with_ruby" }
})

minetest.register_craft({
	type = "shapeless",
	output = "stoneblocks:red_granite_turquoise_block",
	recipe = { "", "stoneblocks:red_granite_block", "stoneblocks:red_granite_block" },
	{"", "stoneblocks:turquoise_glass", ""},
	{"", "", ""}
})

