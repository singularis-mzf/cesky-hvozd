local pot = "sandwiches:pot"
local skillet = "sandwiches:skillet"
if minetest.global_exists("farming") and  farming.mod == "redo" then
  pot = "farming:pot"
  skillet = "farming:skillet"
end

minetest.register_craft({
  output = "sandwiches:classic_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
     {"agriculture:lettuce", "group:food_ham", "agriculture:tomato"},
    {"", "sandwiches:bread_slice", ""},
  },
})
minetest.register_craft({
  output = "sandwiches:classic_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
     {"agriculture:lettuce", "farming:tofu_cooked", "agriculture:tomato"},
    {"", "sandwiches:bread_slice", ""},
  },
})

minetest.register_craft({
  output = "sandwiches:blt_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"agriculture:lettuce", "group:food_bacon" ,"agriculture:tomato"},
    {"", "sandwiches:bread_slice", ""},
  },
})


minetest.register_craft({
  output = "sandwiches:italian_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"flowers:mushroom_brown", "agriculture:tomato", "group:food_cheese"},
    {"", "sandwiches:bread_slice", ""},
  },
})

minetest.register_craft({
  output = "sandwiches:hot_veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"agriculture:tomato", "sandwiches:tabasco", "agriculture:potato"},
    {"", "sandwiches:bread_slice", ""},
  },
  replacements = {{"sandwiches:tabasco", "vessels:glass_bottle"},}
})
minetest.register_craft({
  output = "sandwiches:hot_veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"agriculture:carrot", "sandwiches:tabasco", "group:food_onion"},
    {"", "sandwiches:bread_slice", ""},
  },
  replacements = {{"sandwiches:tabasco", "vessels:glass_bottle"},}
})


minetest.register_craft({
  output = "sandwiches:veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"group:food_cucumber", "agriculture:tomato", "agriculture:potato"},
    {"", "sandwiches:bread_slice", ""},
  },
})
minetest.register_craft({
  output = "sandwiches:veggie_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {"agriculture:carrot", "group:food_onion", "agriculture:sugar_beet"},
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
		"agriculture:potato", "agriculture:potato",
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
    "agriculture:carrot", "agriculture:carrot",
    "group:food_skillet", "group:food_butter", herb,
  },
  replacements = {{"group:food_skillet", skillet }}
})

minetest.register_craft({
  output = "sandwiches:strawberry_jam 5",
  recipe = {
    {"agriculture:strawberry", "group:food_sugar", "agriculture:strawberry"},
    {"group:food_sugar", "group:food_pot", "group:food_sugar"},
    {"agriculture:strawberry", "group:food_sugar", "agriculture:strawberry"},
  },
  replacements = {{"group:food_pot", pot }},
})

minetest.register_craft({
  output = "sandwiches:blueberry_jam 5",
  recipe = {
    {"agriculture:huckleberry", "group:food_sugar", "agriculture:huckleberry"},
    {"group:food_sugar", "group:food_pot", "group:food_sugar"},
    {"agriculture:huckleberry", "group:food_sugar", "agriculture:huckleberry"},
  },
  replacements = {{"group:food_pot", pot }},
})

minetest.register_craft({
  output = "sandwiches:strawberry_jam 5",
  recipe = {
    {"agriculture:strawberry", "agriculture:sugar", "agriculture:strawberry"},
    {"agriculture:sugar", "group:food_pot", "agriculture:sugar"},
    {"agriculture:strawberry", "agriculture:sugar", "agriculture:strawberry"},
  },
  replacements = {{"group:food_pot", pot }},
})

minetest.register_craft({
  output = "sandwiches:blueberry_jam 5",
  recipe = {
    {"agriculture:huckleberry", "agriculture:sugar", "agriculture:huckleberry"},
    {"agriculture:sugar", "group:food_pot", "agriculture:sugar"},
    {"agriculture:huckleberry", "agriculture:sugar", "agriculture:huckleberry"},
  },
  replacements = {{"group:food_pot", pot }},
})
