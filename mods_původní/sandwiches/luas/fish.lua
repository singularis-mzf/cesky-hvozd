minetest.register_craftitem("sandwiches:cooked_salmon", {
    description = "Cooked Salmon",
    on_use = minetest.item_eat(4),
    groups = {food = 4, food_fish_cooked = 1, food_salmon = 1, flammable = 1},
    inventory_image = "sandwiches_salmon_cooked.png"
})
minetest.register_craft({
    type = "cooking",
    output = "sandwiches:cooked_salmon",
    recipe = "ethereal:fish_salmon",
    cooktime = 5,
})

local ingredient = "group:food_tomato"
if minetest.get_modpath("cheese") then
  ingredient = "group:food_cream"
end

if  minetest.global_exists("farming") and  farming.mod == "redo" then

  minetest.register_craftitem("sandwiches:lox_sandwich", {
  	description = "Lox sandwich",
  	on_use = minetest.item_eat(12, "sandwiches:bread_crumbs"),
  	groups = {food = 12, food_sandwich = 1, flammable = 1},
  	inventory_image = "lox_sandwich.png"
  })
  minetest.register_craft({
  	output = "sandwiches:lox_sandwich",
  	recipe = {
  		{"", "sandwiches:bread_slice", ""},
  		{ingredient, "sandwiches:cooked_salmon","group:food_cucumber"},
  		{"", "sandwiches:bread_slice", ""},
  	}
  })

end -- it needs cucumber

if sandwiches.ingredient_support.meat then

minetest.register_craftitem("sandwiches:cooked_trout", {
    description = "Cooked Trout",
    on_use = minetest.item_eat(4),
    groups = {food = 4, food_fish_cooked = 1, food_trout = 1, flammable = 1},
    inventory_image = "sandwiches_trout_cooked.png"
})
minetest.register_craft({
    type = "cooking",
    output = "sandwiches:cooked_trout",
    recipe = "ethereal:fish_trout",
    cooktime = 5,
})

minetest.register_craftitem("sandwiches:trout_sandwich", {
	description = "Trout sandwich",
  on_use = minetest.item_eat(13, "sandwiches:bread_crumbs"),
	groups = {food = 13, food_sandwich = 1, flammable = 1},
	inventory_image = "trout_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:trout_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"group:food_egg", "sandwiches:cooked_trout","group:food_onion"},
		{"", "sandwiches:bread_slice", ""},
	}
})

end -- if eggs are present
