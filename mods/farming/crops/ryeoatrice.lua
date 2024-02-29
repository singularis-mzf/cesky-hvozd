
local S = farming.intllib

--= A nice addition from Ademant's grain mod :)

-- Rye

farming.register_plant("farming:rye", {
	description = S("Rye seed"),
	paramtype2 = "meshoptions",
	inventory_image = "farming_rye_seed.png",
	steps = 8,
	place_param2 = 3
})

minetest.override_item("farming:rye", {
	description = S("Rye"),
	groups = {food_rye = 1, flammable = 4}
})

for i = 1, 8 do
	local override = {
		description = S("Rye"),
	}
	if i < 4 then
		drop = {}
		if i > 1 then
			override.move_resistance = 1
		end
	end
	minetest.override_item("farming:rye_"..i, override)
end

minetest.register_craft({
	output = "farming:flour",
	recipe = {
		{"farming:rye", "farming:rye", "farming:rye"},
		{"farming:rye", "farming:mortar_pestle", ""}
	},
	replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}}
})

-- Oats

farming.register_plant("farming:oat", {
	description = S("Oat seed"),
	paramtype2 = "meshoptions",
	inventory_image = "farming_oat_seed.png",
	steps = 8,
	place_param2 = 3
})

minetest.override_item("farming:oat", {
	description = S("Oats"),
	groups = {food_oats = 1, flammable = 4}
})

minetest.override_item("farming:oat_1", {description = S("Oats"), drop = {}})
minetest.override_item("farming:oat_2", {description = S("Oats"), drop = {}, move_resistance = 1})
minetest.override_item("farming:oat_3", {description = S("Oats"), drop = {}, move_resistance = 1})

for i = 1, 8 do
	local override = {
		description = S("Oats"),
	}
	if i <= 3 then
		drop = {}
		if i >= 2 then
			override.move_resistance = 1
		end
	end
	minetest.override_item("farming:oat_"..i, override)
end

minetest.register_craft({
	output = "farming:flour",
	recipe = {
		{"farming:oat", "farming:oat", "farming:oat"},
		{"farming:oat", "farming:mortar_pestle", ""}
	},
	replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}}
})

-- Multigrain flour

minetest.register_craftitem("farming:flour_multigrain", {
	description = S("Multigrain Flour"),
	inventory_image = "farming_flour_multigrain.png",
	groups = {food_flour = 1, flammable = 1},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:flour_multigrain",
	recipe = {
		"farming:wheat", "farming:barley", "farming:oat",
		"farming:rye", "farming:mortar_pestle"
	},
	replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}}
})

-- Multigrain bread

minetest.register_craftitem("farming:bread_multigrain", {
	description = S("Multigrain Bread"),
	inventory_image = "farming_bread_multigrain.png",
	on_use = minetest.item_eat(7),
	groups = {food_bread = 1, flammable = 2, ch_food = 7}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:bread_multigrain",
	recipe = "farming:flour_multigrain"
})

-- Fuels

minetest.register_craft({
	type = "fuel",
	recipe = "farming:bread_multigrain",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:rye",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:oat",
	burntime = 1
})
