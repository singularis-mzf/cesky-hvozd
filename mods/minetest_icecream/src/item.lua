

-- Load support for MT game translation.
local S = minetest.get_translator("icecream")

--Ice Cream

-- dough
minetest.register_craftitem("icecream:dough", {
	description = S("Cone Dough"),
	inventory_image = "icecream_dough.png",
	on_use = ch_core.item_eat(),
	groups = {ch_food = 1},
})
--  Dought cone
minetest.register_craftitem("icecream:notcone", {
	description = S("Cone-shaped dough"),
	inventory_image = "icecream_notcone.png",
	on_use = ch_core.item_eat(),
	groups = {ch_food = 1},
})
-- cone
minetest.register_craftitem("icecream:cone", {
	description = S("Cone"),
	inventory_image = "icecream_cone.png",
	on_use = ch_core.item_eat(),
	groups = {ch_food = 4},
})

--apple icecream
minetest.register_craftitem("icecream:apple", {
	description = S("Apple IceCream"),
	inventory_image = "icecream_apple.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 8},
})

--pineapple icecream
minetest.register_craftitem("icecream:pineapple", {
	description = S("Pineapple IceCream"),
	inventory_image = "icecream_pineapple.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 8},
})

--banana icecream
minetest.register_craftitem("icecream:banana", {
	description = S("Banana IceCream"),
	inventory_image = "icecream_banana.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 8},
})

--carrot icecream
minetest.register_craftitem("icecream:carrot", {
	description = S("Carrot IceCream"),
	inventory_image = "icecream_carrot.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 6},
})

--chocolate icecream
minetest.register_craftitem("icecream:chocolate", {
	description = S("Chocolate IceCream"),
	inventory_image = "icecream_chocolate.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 8},
})

--chocolate with cookies icecream
minetest.register_craftitem("icecream:chocolate_with_cookies", {
	description = S("Chocolate with Cookies IceCream"),
	inventory_image = "icecream_chocolate_and_cookie.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 12},
})

--vanilla with cookies icecream
minetest.register_craftitem("icecream:vanilla_with_cookies", {
	description = S("Vanilla with Cookies IceCream"),
	inventory_image = "icecream_vanilla_and_cookie.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 12},
})

--orange icecream
minetest.register_craftitem("icecream:orange", {
	description = S("Orange IceCream"),
	inventory_image = "icecream_orange.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 8},
})

--watermelon icecream
minetest.register_craftitem("icecream:watermelon", {
	description = S("Watermelon IceCream"),
	inventory_image = "icecream_watermelon.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 6},
})
--Vanilla icecream
minetest.register_craftitem("icecream:vanilla", {
	description = S("Vanilla IceCream"),
	inventory_image = "icecream_vanilla.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 10},
})
--Pumpkin icecream
minetest.register_craftitem("icecream:pumpkin", {
	description = S("Pumpkin IceCream"),
	inventory_image = "icecream_pumpkin.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 6},
})
--Mint icecream
minetest.register_craftitem("icecream:mint", {
	description = S("Mint IceCream"),
	inventory_image = "icecream_mint.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 12},
})
-- Blueberries Icecream
minetest.register_craftitem("icecream:blueberries", {
	description = S("Blueberries IceCream"),
	inventory_image = "icecream_blueberries.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 6},
})
-- Strawberry Icecream
minetest.register_craftitem("icecream:strawberry", {
	description = S("Strawberry IceCream"),
	inventory_image = "icecream_strawberry.png",
	on_use = ch_core.item_eat(),
	groups = {food_icecream = 1, ch_food = 10},
})
