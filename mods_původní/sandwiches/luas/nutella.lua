minetest.register_node("sandwiches:noyella_block", {
	description = "Noyella block",
	groups = {snappy = 1 , oddly_breakable_by_hand = 3, not_in_creative_inventory=1, flammable = 1},
	paramtype2 = "facedir",
	tiles = {"noyella_block_top.png",
		"noyella_block_bottom.png",
		"noyella_block_side.png",
		"noyella_block_side.png",
		"noyella_block_side.png",
		"noyella_block_front.png"
	},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craftitem("sandwiches:noyella_sandwich", {
	description = "noyella sandwich",
	on_use = minetest.item_eat(8, "sandwiches:bread_crumbs"),
	groups = {food_sandwich = 1},
	inventory_image = "noyella_sandwich.png"
})

minetest.register_craftitem("sandwiches:noyella_spread", {
	description = "Noyella spread",
	on_use = minetest.item_eat(2),
	groups = {food_nutella = 1, food_noyella = 1, food_chocolate_spead = 1, flammable = 1},
	inventory_image = "noyella_spread.png"
})

-- CRAFTS --

minetest.register_craft({
	output = "sandwiches:noyella_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"sandwiches:noyella_spread", "sandwiches:noyella_spread", "sandwiches:noyella_spread"},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craft({
	output = "sandwiches:noyella_spread 5",
	type = "shapeless",
	recipe = {
		"farming:cocoa_beans", "farming:cocoa_beans", "farming:cocoa_beans",
		"group:food_sugar", "group:food_sugar", "group:food_sugar",
		"moretrees:acorn", "moretrees:acorn", "moretrees:acorn",
	}
})

if minetest.get_modpath("x_farming") then
	minetest.register_craft({
		output = "sandwiches:noyella_spread 5",
		type = "shapeless",
		recipe = {
			"x_farming:cocoa_bean", "x_farming:cocoa_bean", "x_farming:cocoa_bean",
			"group:food_sugar", "group:food_sugar", "group:food_sugar",
			"moretrees:acorn", "moretrees:acorn", "moretrees:acorn",
		}
	})
end -- if x_farming is present
if minetest.get_modpath("cacaotree")then
	minetest.register_craft({
		output = "sandwiches:noyella_spread 5",
		type = "shapeless",
		recipe = {
			"cacaotree:cacao_beans", "cacaotree:cacao_beans", "cacaotree:cacao_beans",
			"group:food_sugar", "group:food_sugar", "group:food_sugar",
			"moretrees:acorn", "moretrees:acorn", "moretrees:acorn",
		}
	})
	minetest.register_craft({
		output = "sandwiches:noyella_spread 5",
		type = "shapeless",
		recipe = {
			"cacaotree:cacao_beans", "cacaotree:cacao_beans", "cacaotree:cacao_beans",
			"x_farming:sugar", "x_farming:sugar", "x_farming:sugar",
			"moretrees:acorn", "moretrees:acorn", "moretrees:acorn",
		}
	})
end -- if cool_trees with cacaotree is present

minetest.register_craft({
	output = "sandwiches:noyella_block",
	recipe = {
		{"sandwiches:noyella_spread", "sandwiches:noyella_spread", "sandwiches:noyella_spread"},
		{"sandwiches:noyella_spread", "sandwiches:noyella_spread", "sandwiches:noyella_spread"},
		{"sandwiches:noyella_spread", "sandwiches:noyella_spread", "sandwiches:noyella_spread"}
	}
})

minetest.register_craft({
	output = "sandwiches:noyella_spread 9",
	type = "shapeless",
	recipe = {"sandwiches:noyella_block"}
})

minetest.register_alias("sandwiches:nutella_block", "sandwiches:noyella_block")
minetest.register_alias("sandwiches:acorn_nutella", "sandwiches:noyella_spread")
minetest.register_alias("sandwiches:nutella_sandwich", "sandwiches:noyella_sandwich")
