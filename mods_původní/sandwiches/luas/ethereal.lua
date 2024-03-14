-- banana_and_chocolate_sandwich, strawberry jam and strawberry_jam_sandwich are added.

minetest.register_craftitem("sandwiches:strawberry_jam", {
    description = "Strawberry jam",
    on_use = minetest.item_eat(2),
    groups = {food_jam = 1, },
    inventory_image = "strawberry_jam.png"
})

minetest.register_craftitem("sandwiches:strawberry_jam_sandwich", {
    description = "Strawberry Jam Sandwich",
    on_use = minetest.item_eat(7, "sandwiches:bread_crumbs"),
    groups = {food_sandwich = 1},
    inventory_image = "strawberry_jam_sandwich.png"
})

minetest.register_craftitem("sandwiches:banana_and_chocolate_sandwich", {
	description = "Banana and chocolate sandwich",
	on_use = minetest.item_eat(7, "sandwiches:bread_crumbs"),
	groups = {food_sandwich = 1},
	inventory_image = "banana_and_chocolate_sandwich.png"
})

minetest.register_craftitem("sandwiches:elvis_sandwich", {
    description = "Elvis sandwich",
    on_use = minetest.item_eat(8, "sandwiches:bread_crumbs"),
    groups = {food_sandwich = 1},
    inventory_image = "elvis_sandwich.png"
})

-- CRAFTS --

minetest.register_craft({
	output = "sandwiches:strawberry_jam",
	recipe = {
		{"group:food_strawberry", "group:food_sugar", "group:food_strawberry"},
		{"group:food_sugar", "group:food_pot", "group:food_sugar"},
		{"group:food_strawberry", "group:food_sugar", "group:food_strawberry"},
	},
	replacements = {{"group:food_pot", "group:food_pot"}}
})

minetest.register_craft({
	output = "sandwiches:strawberry_jam",
	recipe = {
		{"ethereal:strawberry", "group:food_sugar", "ethereal:strawberry"},
		{"group:food_sugar", "group:food_pot", "group:food_sugar"},
		{"ethereal:strawberry", "group:food_sugar", "ethereal:strawberry"},
	},
	replacements = {{"group:food_pot", "group:food_pot"}}
})

minetest.register_craft({
	output = "sandwiches:strawberry_jam_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"sandwiches:strawberry_jam", "sandwiches:strawberry_jam", "sandwiches:strawberry_jam"},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craft({
	output = "sandwiches:banana_and_chocolate_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"group:food_banana", "farming:chocolate_dark", "group:food_banana"},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craft({
	output = "sandwiches:banana_and_chocolate_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"ethereal:banana", "farming:chocolate_dark", "ethereal:banana"},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craft({
	output = "sandwiches:elvis_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"ethereal:banana", "sandwiches:peanut_butter", "sandwiches:crispy_bacon"},
		{"", "sandwiches:bread_slice", ""},
	}
})