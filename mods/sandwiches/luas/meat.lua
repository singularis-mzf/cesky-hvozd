local board = "sandwiches:cutting_board"
local S = minetest.get_translator("sandwiches")
if minetest.global_exists("farming") and  farming.mod == "redo" then
  board = "farming:cutting_board"
end

minetest.register_craftitem("sandwiches:ham", {
    description = S("Ham"),
    on_use = ch_core.item_eat(),
    groups = {food = 3, food_ham = 1, food_meat = 1, flammable = 1, ch_food = 3},
    inventory_image = "sandwiches_ham.png"
})

minetest.register_craftitem("sandwiches:chicken_strips", {
    description = S("Chicken strips"),
    on_use = ch_core.item_eat(),
    groups = {food = 2, food_chicken_strips = 1, food_meat = 1, flammable = 1, ch_food = 2},
    inventory_image = "sandwiches_chicken_strips.png"
})
minetest.register_craft({
	output = "sandwiches:chicken_strips 3",
	type = "shapeless";
	recipe = {"group:food_chicken", "group:food_cutting_board"},
	replacements = {{"group:food_cutting_board", board }}
})

minetest.register_craftitem("sandwiches:raw_bacon", {
    description = S("Raw Bacon"),
    on_use = ch_core.item_eat(),
    groups = {food = 1, food_bacon_raw = 1, food_meat = 1, flammable = 1, ch_food = 1},
    inventory_image = "sandwiches_raw_bacon.png"
})
minetest.register_craftitem("sandwiches:crispy_bacon", {
    description = S("Crispy Bacon"),
    on_use = ch_core.item_eat(),
    groups = {food = 3, food_bacon = 1, food_meat = 1, flammable = 1, ch_food = 3},
    inventory_image = "sandwiches_crispy_bacon.png"
})
minetest.register_craft({
    type = "cooking",
    output = "sandwiches:crispy_bacon",
    recipe = "sandwiches:raw_bacon",
    cooktime = 5,
})
minetest.register_craft({
	output = "sandwiches:raw_bacon 3",
	type = "shapeless";
	recipe = {"group:food_pork_raw", "group:food_cutting_board"},
	replacements = {{"group:food_cutting_board", board }}
})

if minetest.get_modpath("mobs") then
  minetest.register_craft({
  	output = "sandwiches:ham 3",
  	type = "shapeless";
  	recipe = {"mobs:meat", "group:food_cutting_board"},
  	replacements = {{"group:food_cutting_board", board }}
  })
end
if minetest.get_modpath("petz") then
  minetest.register_craft({
  	output = "sandwiches:ham 3",
  	type = "shapeless";
  	recipe = {"petz:steak", "group:food_cutting_board"},
  	replacements = {{"group:food_cutting_board", board }}
  })
  minetest.register_craft({
    output = "sandwiches:chicken_strips 3",
    type = "shapeless";
    recipe = {"petz:roasted_chicken", "group:food_cutting_board"},
    replacements = {{"group:food_cutting_board", board }}
  })
  minetest.register_craft({
  	output = "sandwiches:raw_bacon 3",
  	type = "shapeless";
  	recipe = {"petz:raw_porkchop", "group:food_cutting_board"},
    replacements = {{"group:food_cutting_board", board }}
  })
end
if minetest.get_modpath("animalia") then
  minetest.register_craft({
  	output = "sandwiches:ham 3",
  	type = "shapeless";
  	recipe = {"animalia:beef_cooked", "group:food_cutting_board"},
  	replacements = {{"group:food_cutting_board", board }}
  })
  minetest.register_craft({
    output = "sandwiches:chicken_strips 3",
    type = "shapeless";
    recipe = {"animalia:poultry_cooked", "group:food_cutting_board"},
    replacements = {{"group:food_cutting_board", board }}
  })
  minetest.register_craft({
  	output = "sandwiches:raw_bacon 3",
  	type = "shapeless";
  	recipe = {"animalia:porkchop_raw", "group:food_cutting_board"},
  	replacements = {{"group:food_cutting_board", board }}
  })
end
