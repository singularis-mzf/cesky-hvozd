--
-- ccloth
-- License:GPLv3
--

--
-- Cool Cloth
--

local S = minetest.get_translator("ccloth")

--Gray Hoodie

player_api.register_cloth("ccloth:gray_hoodie", {
	description = S("Gray Hoodie"),
	texture = "ccloth_gray_hoodie.png",
	inventory_image = "ccloth_gray_hoodie_inv.png",
	wield_image = "ccloth_gray_hoodie_inv.png",
	preview = "ccloth_gray_hoodie_preview.png",
	gender = "unisex",
	groups = {cloth = 2},
	attach = "ccloth:gray_hoodie_hood",
})

player_api.register_cloth("ccloth:gray_hoodie_hood", {
	attached = true,
	texture = "ccloth_gray_hoodie_hood.png",
	groups = {cloth = 1},
})

minetest.register_craft({
	output = "ccloth:gray_hoodie",
	type = "shaped",
	recipe = {
		{"fabric:grey", "", "fabric:grey"},
		{"fabric:dark_grey", "fabric:white", "fabric:grey"},
		{"fabric:dark_grey", "fabric:grey", "fabric:dark_grey"},
	}
})

--Blue Jeans

player_api.register_cloth("ccloth:blue_jeans", {
	description = S("Blue Jeans"),
	texture = "ccloth_blue_jeans.png",
	inventory_image = "ccloth_blue_jeans_inv.png",
	wield_image = "ccloth_blue_jeans_inv.png",
	preview = "ccloth_blue_jeans_preview.png",
	gender = "unisex",
	groups = {cloth = 3},
})

minetest.register_craft({
	output = "ccloth:blue_jeans",
	type = "shaped",
	recipe = {
		{"fabric:blue", "fabric:blue", "fabric:blue"},
		{"fabric:white", "", "fabric:white"},
		{"fabric:blue", "", "fabric:blue"},
	}
})

--Black Sneakers

player_api.register_cloth("ccloth:black_sneakers", {
	description = S("Black Sneakers"),
	texture = "ccloth_black_sneakers.png",
	inventory_image = "ccloth_black_sneakers_inv.png",
	wield_image = "ccloth_black_sneakers_inv.png",
	preview = "ccloth_black_sneakers_preview.png",
	gender = "unisex",
	groups = {cloth = 4},
})

minetest.register_craft({
	output = "ccloth:black_sneakers",
	type = "shaped",
	recipe = {
		{"farming:string", "", "farming:string"},
		{"fabric:black", "", "fabric:black"},
		{"", "", ""},
	}
})
