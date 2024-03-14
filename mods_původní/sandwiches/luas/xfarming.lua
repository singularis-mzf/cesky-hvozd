local ingredient = "group:food_lettuce"

local pot = "sandwiches:pot"
local skillet = "sandwiches:skillet"
if minetest.global_exists("farming") and  farming.mod == "redo" then
  pot = "farming:pot"
  skillet = "farming:skillet"

  ingredient = "group:food_cucumber"
end

if sandwiches.ingredient_support.dairy then
  ingredient = "group:food_cheese"
end

-- SANDWICHES --
minetest.register_craftitem("sandwiches:po_boy_sandwich", {
	description = "Po\'boy sandwich",
	on_use = minetest.item_eat(7, "sandwiches:bread_crumbs"),

	groups = {food = 7, food_sandwich = 1},
	inventory_image = "po_boy_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:po_boy_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{ingredient, "x_farming:shrimp_cooked", "group:food_tomato"},
		{"", "sandwiches:bread_slice", ""},
	}
})


-- ALREADY EXISTING SANDWICHES CRAFT --

minetest.register_craft({
  output = "sandwiches:hot_veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"x_farming:carrot", "sandwiches:tabasco", "x_farming:potato"},
    {"", "sandwiches:bread_slice", ""},
  },
  replacements = {{"sandwiches:tabasco", "vessels:glass_bottle"},}
})
minetest.register_craft({
  output = "sandwiches:hot_veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"x_farming:carrot", "sandwiches:tabasco", "group:food_onion"},
    {"", "sandwiches:bread_slice", ""},
  },
  replacements = {{"sandwiches:tabasco", "vessels:glass_bottle"},}
})

minetest.register_craft({
  output = "sandwiches:veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"group:food_cucumber", "x_farming:carrot", "x_farming:potato"},
    {"", "sandwiches:bread_slice", ""},
  },
})
minetest.register_craft({
  output = "sandwiches:veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"x_farming:carrot", "group:food_onion", "x_farming:beetroot"},
    {"", "sandwiches:bread_slice", ""},
  },
})
minetest.register_craft({
  output = "sandwiches:banana_and_chocolate_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"group:food_banana", "x_farming:chocolate", "group:food_banana"},
    {"", "sandwiches:bread_slice", ""},
  },
})

-- NON SANDWICH CRAFTS --
local herb = "group:food_parsley"
local rosm = "group:food_pepper_ground"
if sandwiches.ingredient_support.herbs then
  herb = "potted_farming:sage"
  rosm = "group:food_rosemary"
end
minetest.register_craft({
	output = "sandwiches:roasted_potatoes 5",
	type = "shapeless",
	recipe = {
		"x_farming:potato", "x_farming:potato",
		"group:food_skillet", "group:food_oil", rosm,
	},
	replacements = {
    {"group:food_skillet", skillet },
    {"group:food_pepper_ground", "vessels:glass_bottle"},
    {"group:food_oil", "vessels:glass_bottle"}, }
})
minetest.register_craft({
  output = "sandwiches:butter_carrots 5",
  type = "shapeless",
  recipe = {
    "x_farming:carrot", "x_farming:carrot",
    "group:food_skillet", "group:food_butter", herb,
  },
  replacements = {{"group:food_skillet", skillet }}
})

minetest.register_craft({
  output = "sandwiches:strawberry_jam 5",
  recipe = {
    {"x_farming:strawberry", "group:food_sugar", "x_farming:strawberry"},
    {"group:food_sugar", "group:food_pot", "group:food_sugar"},
    {"x_farming:strawberry", "group:food_sugar", "x_farming:strawberry"},
  },
  replacements = {{"group:food_pot", pot }},
})

minetest.register_craft({
  output = "sandwiches:strawberry_jam 5",
  recipe = {
    {"x_farming:strawberry", "x_farming:sugar", "x_farming:strawberry"},
    {"x_farming:sugar", "group:food_pot", "x_farming:sugar"},
    {"x_farming:strawberry", "x_farming:sugar", "x_farming:strawberry"},
  },
  replacements = {{"group:food_pot", pot }},
})
