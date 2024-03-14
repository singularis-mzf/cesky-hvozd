minetest.register_craftitem("ch_overrides:salmon", {
	description = "losos (syrový)",
	groups = {food_fish_raw = 1, food_salmon = 1, ch_food = 2},
	inventory_image = "sandwiches_salmon_cooked.png^[brighten",
	on_use = ch_core.item_eat(),
})

minetest.register_craftitem("ch_overrides:trout", {
	description = "pstruh (syrový)",
	groups = {food_fish_raw = 1, food_trout = 1, ch_food = 2},
	inventory_image = "sandwiches_trout_cooked.png^[brighten",
	on_use = ch_core.item_eat(),
})

minetest.register_craft({
	type = "cooking",
	output = "sandwiches:cooked_salmon",
	recipe = "ch_overrides:salmon",
	cooktime = 5,
})
minetest.register_craft({
	type = "cooking",
	output = "sandwiches:cooked_trout",
	recipe = "ch_overrides:trout",
	cooktime = 5,
})
