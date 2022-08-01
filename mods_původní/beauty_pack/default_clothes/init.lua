--
-- default_clothes
-- License:GPLv3
--

--
-- Default Clothes
--

minetest.register_craft({
	output = "player_api:cloth_female_upper_default",
	type = "shaped",
	recipe = {
		{"fabric:violet", "", "fabric:violet"},
		{"fabric:dark_grey", "fabric:dark_grey", "fabric:dark_grey"},
		{"fabric:violet", "fabric:violet", "fabric:violet"},
	}
})

minetest.register_craft({
	output = "player_api:cloth_male_upper_default",
	type = "shaped",
	recipe = {
		{"fabric:black", "", "fabric:black"},
		{"fabric:green", "fabric:green", "fabric:green"},
		{"fabric:brown", "fabric:brown", "fabric:brown"},
	}
})

minetest.register_craft({
	output = "player_api:cloth_male_lower_default",
	type = "shaped",
	recipe = {
		{"fabric:blue", "fabric:blue", "fabric:blue"},
		{"fabric:blue", "", "fabric:blue"},
		{"fabric:black", "", "fabric:black"},
	}
})

minetest.register_craft({
	output = "player_api:cloth_female_lower_default",
	type = "shaped",
	recipe = {
		{"fabric:blue", "fabric:blue", "fabric:blue"},
		{"fabric:white", "", "fabric:white"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "player_api:cloth_female_head_default",
	type = "shaped",
	recipe = {
		{"fabric:pink", "", ""},
		{"", "fabric:pink", ""},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "player_api:cloth_unisex_footwear_default",
	type = "shaped",
	recipe = {
		{"fabric:black", "", "fabric:black"},
		{"fabric:black", "", "fabric:black"},
		{"", "", ""},
	}
})
