-- same exact recipes as the ones in farming's utensils.lua

minetest.register_craftitem("sandwiches:pot", {
	description = "Cooking Pot",
	inventory_image = "cooking_pot.png",
	groups = {food_pot = 1}
})
minetest.register_craft({
	output = "sandwiches:pot",
	recipe = {
		{"group:stick", "default:steel_ingot", "default:steel_ingot"},
		{"", "default:steel_ingot", "default:steel_ingot"}
	}
})
--[[
minetest.register_craftitem("sandwiches:baking_tray", {
	description = "Baking Tray",
	inventory_image = "baking_tray.png",
	groups = {food_baking_tray = 1}
})
minetest.register_craft({
	output = "sandwiches:baking_tray",
	recipe = {
		{"default:clay_brick", "default:clay_brick", "default:clay_brick"},
		{"default:clay_brick", "", "default:clay_brick"},
		{"default:clay_brick", "default:clay_brick", "default:clay_brick"}
	}
})
]]--
minetest.register_craftitem("sandwiches:skillet", {
	description = "Skillet",
	inventory_image = "skillet.png",
	groups = {food_skillet = 1}
})
minetest.register_craft({
	output = "sandwiches:skillet",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"", "default:steel_ingot", ""},
		{"", "", "group:stick"}
	}
})

minetest.register_craftitem("sandwiches:mortar_pestle", {
	description = "Mortar and Pestle",
	inventory_image = "mortar_pestle.png",
	groups = {food_mortar_pestle = 1}
})
minetest.register_craft({
	output = "sandwiches:mortar_pestle",
	recipe = {
		{"default:stone", "group:stick", "default:stone"},
		{"", "default:stone", ""}
	}
})

minetest.register_craftitem("sandwiches:cutting_board", {
	description = "Cutting Board",
	inventory_image = "cutting_board.png",
	groups = {food_cutting_board = 1}
})

minetest.register_craft({
	output = "sandwiches:cutting_board",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"", "group:stick", ""},
		{"", "", "group:wood"}
	}
})

minetest.register_craftitem("sandwiches:mixing_bowl", {
	description = "Glass Mixing Bowl",
	inventory_image = "mixing_bowl.png",
	groups = {food_mixing_bowl = 1,}
})
minetest.register_craft({
	output = "sandwiches:mixing_bowl",
	recipe = {
		{"", "", ""},
		{"default:glass", "group:stick", "default:glass"},
		{"", "default:glass", ""}
	}
})
