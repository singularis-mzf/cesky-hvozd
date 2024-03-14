-- TODO --

minetest.register_craftitem("sandwiches:ketchup", {
	description = "Ketchup bottle",
	inventory_image = "ketchup.png",
	groups = {food_sauce = 1, food_ketchup = 1},
})
minetest.register_craft({
	output = "sandwiches:ketchup 5",
	type = "shapeless";
	recipe = {"group:food_tomato", "group:food_tomato", "group:food_tomato",
		"group:food_sugar", "group:food_sugar", "group:food_sugar",
		"group:food_pot", "vessels:glass_bottle",
	},
	replacements = {{"group:food_pot", "group:food_pot"}}
})

minetest.register_craftitem("sandwiches:spicy_ketchup", {
description = "Spicy ketchup bottle",
inventory_image = "ketchup.png", -- colorize more red ?
groups = {food_sauce = 1, food_ketchup = 1, food_spicy = 1, food_hot = 1},
})
minetest.register_craft({
	output = "sandwiches:spicy_ketchup 5",
	type = "shapeless";
	recipe = {"group:food_tomato", "group:food_tomato", "group:food_tomato",
		"group:food_sugar", "group:food_sugar", "group:food_chili_pepper",
		"group:food_pot", "vessels:glass_bottle", "group:food_chili_pepper"
	},
	replacements = {{"group:food_pot", "group:food_pot"}}
})

minetest.register_craftitem("sandwiches:maionaisse", {
	description = "Maionaisse",
	inventory_image = "maionaisse.png",
	groups = {food_sauce = 1, food_maionaisse = 1},
})
minetest.register_craft({
	output = "sandwiches:maionaisse 5",
	type = "shapeless";
	recipe = {"group:food_egg", "group:food_egg", "group:food_oil",
		"group:food_oil", "group:food_lemon", "group:food_lemon",
		"group:food_mixing_bowl", "vessels:glass_bottle",
	},
	replacements = {{"group:food_mixing_bowl", "group:food_mixing_bowl"}}
})
