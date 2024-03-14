local skillet = "sandwiches:skillet"
local mix = "sandwiches:mixing_bowl"
if minetest.global_exists("farming") and  farming.mod == "redo" then
  skillet = "farming:skillet"
	mix = "farming:mixing_bowl"
end

-- food_toasted = 1 means sandwich wich craft uses skillet+butter or uses garlic bread slice

minetest.register_craftitem("sandwiches:grilled_hot_cheesy_sandwich", {
		description = "Grilled hot cheese sandwich",
		on_use = minetest.item_eat(10, "sandwiches:bread_crumbs"),
		groups = {food = 10, food_sandwich = 1, food_toasted = 1},
		inventory_image = "grilled_hot_cheesy_sandwich.png"
})
minetest.register_craft({
		output = "sandwiches:grilled_hot_cheesy_sandwich",
		recipe = {
			{"", "sandwiches:bread_slice", ""},
			{"group:food_cheese", "sandwiches:tabasco", "group:food_cheese"},
			{"group:food_skillet", "sandwiches:bread_slice", "group:food_butter"},
		},
		replacements = {{"group:food_skillet", skillet}, {"sandwiches:tabasco","vessels:glass_bottle"}}
})

--garlic bread done right
minetest.register_craftitem("sandwiches:garlic_bread", {
		description = "Garlic bread",
		on_use = minetest.item_eat(4, "sandwiches:bread_crumbs"),
		groups = {food = 4, food_garlic_bread = 1},
		inventory_image = "sandwiches_garlic_bread_slice.png"
})
minetest.register_craft({
		output = "sandwiches:garlic_bread 2",
		recipe = {
			{"group:food_garlic_clove", "group:food_garlic_clove", "group:food_garlic_clove"},
			{"group:food_garlic_clove", "sandwiches:bread_slice", "group:food_garlic_clove"},
			{"group:food_skillet", "sandwiches:bread_slice", "group:food_butter"},
		},
		replacements = {{"group:food_skillet", skillet}}
})

minetest.register_craftitem("sandwiches:tasty_garlic_sandwich", {
		description = "Tasty garlic sandwich",
		on_use = minetest.item_eat(16, "sandwiches:bread_crumbs"),
		groups = {food = 16, food_sandwich = 1, food_toasted = 1},
		inventory_image = "tasty_garlic_sandwich.png"
})
minetest.register_craft({
		output = "sandwiches:tasty_garlic_sandwich",
		recipe = {
			{"", "sandwiches:garlic_bread", ""},
			{"group:food_tomato", "group:food_ham", "group:food_cheese"},
			{"", "sandwiches:garlic_bread", ""},
		},
})

minetest.register_craftitem("sandwiches:fancy_garlic_sandwich", {
		description = "Fancy garlic sandwich",
		on_use = minetest.item_eat(18, "sandwiches:bread_crumbs"),
		groups = {food = 18, food_sandwich = 1, food_toasted = 1},
		inventory_image = "fancy_garlic_sandwich.png"
})
minetest.register_craft({
		output = "sandwiches:fancy_garlic_sandwich",
		recipe = {
			{"", "sandwiches:garlic_bread", ""},
			{"group:food_bacon", "sandwiches:trifolat_mushrooms", "group:food_cheese"},
			{"", "sandwiches:garlic_bread", ""},
		},
})

-- croque monsier, croque madame --- need GRUYERE
local cheese = "group:food_cheese"
if minetest.get_modpath("cheese") then
	cheese = "cheese:gruyere"
end

if minetest.registered_items["sandwiches:ham"] then

minetest.register_craftitem("sandwiches:croque_monsieur", {
		description = "Croque Monsier",
		on_use = minetest.item_eat(13, "sandwiches:bread_crumbs"),
		groups = {food = 13, food_sandwich = 1, food_toasted = 1},
		inventory_image = "croque_monsieur.png"
})
minetest.register_craft({
		output = "sandwiches:croque_monsieur",
		recipe = {
			{"", "sandwiches:bread_slice", ""},
			{cheese, "group:food_ham", cheese},
			{"group:food_skillet", "sandwiches:bread_slice", "group:food_butter"},
		},
		replacements = {{"group:food_skillet", skillet}}
})

end

if minetest.registered_items["sandwiches:chicken_strips"] then

minetest.register_craftitem("sandwiches:croque_madame", {
		description = "Croque madame",
		on_use = minetest.item_eat(16, "sandwiches:bread_crumbs"),
		groups = {food = 16, food_sandwich = 1, food_toasted = 1},
		inventory_image = "croque_madame.png"
})
minetest.register_craft({
		output = "sandwiches:croque_madame",
		recipe = {
			{"", "sandwiches:bread_slice", "group:food_egg_fried"},
			{cheese, "sandwiches:chicken_strips", cheese},
			{"group:food_skillet", "sandwiches:bread_slice", "group:food_butter"},
		},
		replacements = {{"group:food_skillet", skillet}}
})

end
--[[
minetest.register_craft({
  output = "sandwiches:croque_madame",
  type = "shapeless";
  recipe = {"group:food_egg_fried", "sandwiches:croque_monsieur"},
})
]]--
