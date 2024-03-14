-- SANDWHICHES --
if  minetest.global_exists("farming") and  farming.mod == "redo" then -- need pepper

	minetest.register_craftitem("sandwiches:hamwich", {
		description = "Hamwich",
		on_use = minetest.item_eat(11, "sandwiches:bread_crumbs"),
		groups = {food_sandwich = 1},
		inventory_image = "hamwich.png"
	})
	minetest.register_craft({
		output = "sandwiches:hamwich",
		recipe = {
			{"", "sandwiches:bread_slice", ""},
			{"group:food_pepper", "bbq:hamburger_patty", "group:food_cheese"},
			{"", "sandwiches:bread_slice", ""},
		}
	})
	
end

minetest.register_craftitem("sandwiches:jerky_sandwich", {
	description = "Jerky sandwich",
	on_use = minetest.item_eat(11, "sandwiches:bread_crumbs"),
	groups = {food_sandwich = 1},
	inventory_image = "jerky_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:jerky_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"sandwiches:tabasco", "bbq:beef_jerky", "group:food_cheese"},
		{"", "sandwiches:bread_slice", ""},
	},
	replacements = {{"sandwiches:tabasco", "vessels:glass_bottle"},}
})

--NON SANDWICH ITEMS CRAFT --

minetest.register_craft({
	output = "sandwiches:ham 3",
	type = "shapeless";
	recipe = {"bbq:beef", "group:food_cutting_board"},
	replacements = {{"group:food_cutting_board", "farming:cutting_board"}}
})

minetest.register_craft({
	output = "sandwiches:caramelized_onion 4", -- added an use to molasses
	type = "shapeless";
	recipe = {"group:food_onion", "group:food_onion", "bbq:molasses", "group:food_skillet"},
	replacements = {{"group:food_skillet", "farming:skillet"}}
})
