
local S = farming.intllib
local expect_compactor = minetest.settings:get_bool("ch_expect_compactor", false)
local expect_technic = minetest.settings:get_bool("ch_expect_technic", false)

--= filter sea water into river water
minetest.register_craft({
	output = "bucket:bucket_river_water",
	recipe = {
		{"farming:hemp_fibre"},
		{"farming:hemp_fibre"},
		{"bucket:bucket_water"}
	}
})

--= glass of water

minetest.register_craftitem("farming:glass_water", {
	description = S("Glass of Water"),
	inventory_image = "farming_water_glass.png",
	groups = {food_water_glass = 1, flammable = 3, vessel = 1},
})

minetest.register_craft({
	output = "farming:glass_water 4",
	recipe = {
		{"vessels:drinking_glass", "vessels:drinking_glass"},
		{"vessels:drinking_glass", "vessels:drinking_glass"},
		{"bucket:bucket_river_water", ""}
	},
	replacements = {{"bucket:bucket_river_water", "bucket:bucket_empty"}}
})

minetest.register_craft({
	output = "farming:glass_water 4",
	recipe = {
		{"vessels:drinking_glass", "vessels:drinking_glass"},
		{"vessels:drinking_glass", "vessels:drinking_glass"},
		{"bucket:bucket_water", "farming:hemp_fibre"}
	},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
})

if minetest.get_modpath("bucket_wooden") then

	minetest.register_craft({
		output = "farming:glass_water 4",
		recipe = {
			{"vessels:drinking_glass", "vessels:drinking_glass"},
			{"vessels:drinking_glass", "vessels:drinking_glass"},
			{"group:water_bucket_wooden", "farming:hemp_fibre"}
		},
		replacements = {{"group:water_bucket_wooden", "bucket_wooden:bucket_empty"}}
	})
end

--= Sugar

minetest.register_craftitem("farming:sugar", {
	description = S("Sugar"),
	inventory_image = "farming_sugar.png",
	groups = {food_sugar = 1, flammable = 3}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 3,
	output = "farming:sugar 2",
	recipe = "default:papyrus"
})

--= Sugar caramel

minetest.register_craftitem("farming:caramel", {
	description = S("Caramel"),
	inventory_image = "farming_caramel.png",
})

minetest.register_craft({
	type = "cooking",
	cooktime = 6,
	output = "farming:caramel",
	recipe = "group:food_sugar",
})

--= Salt

minetest.register_node("farming:salt", {
	description = S("Salt"),
	inventory_image = "farming_salt.png",
	wield_image = "farming_salt.png",
	drawtype = "plantlike",
	visual_scale = 0.8,
	paramtype = "light",
	tiles = {"farming_salt.png"},
	groups = {food_salt = 1, vessel = 1, dig_immediate = 3,
			attached_node = 1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	-- special function to make salt crystals form inside water
	dropped_step = function(self, pos, dtime)

		self.ctimer = (self.ctimer or 0) + dtime
		if self.ctimer < 15.0 then return end
		self.ctimer = 0

		local needed

		if self.node_inside
		and self.node_inside.name == "default:water_source" then
			needed = 8

		elseif self.node_inside
		and self.node_inside.name == "default:river_water_source" then
			needed = 9
		end

		if not needed then return end

		local objs = core.get_objects_inside_radius(pos, 0.5)

		if not objs or #objs ~= 1 then return end

		local salt, ent = nil, nil

		for k, obj in pairs(objs) do

			ent = obj:get_luaentity()

			if ent and ent.name == "__builtin:item"
			and ent.itemstring == "farming:salt " .. needed then

				obj:remove()

				core.add_item(pos, "farming:salt_crystal")

				return false -- return with no further action
			end
		end
	end
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:salt",
	recipe = "bucket:bucket_water",
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:salt",
	recipe = "default:water_source",
})

--= Salt Crystal

minetest.register_node("farming:salt_crystal", {
	description = S("Salt crystal"),
	inventory_image = "farming_salt_crystal.png",
	wield_image = "farming_salt_crystal.png",
	drawtype = "plantlike",
	visual_scale = 0.8,
	paramtype = "light",
	light_source = 1,
	tiles = {"farming_salt_crystal.png"},
	groups = { dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
})
minetest.register_craft({
	output = "farming:salt 10",
	recipe = {
		{"farming:salt_crystal", "farming:mortar_pestle"}
	},
	replacements = {{"farming:mortar_pestle", "farming:mortar_pestle"}}
})
if not expect_compactor then
minetest.register_craft({
	output = "farming:salt_crystal",
	recipe = {
		{"farming:salt", "farming:salt", "farming:salt"},
		{"farming:salt", "farming:salt", "farming:salt"},
		{"farming:salt", "farming:salt", "farming:salt"}
	}
})
end

--= Rose Water

minetest.register_node("farming:rose_water", {
	description = S("Rose Water"),
	inventory_image = "farming_rose_water.png",
	wield_image = "farming_rose_water.png",
	drawtype = "plantlike",
	visual_scale = 0.8,
	paramtype = "light",
	tiles = {"farming_rose_water.png"},
	groups = {food_rose_water = 1, vessel = 1, dig_immediate = 3,
			attached_node = 1},
	sounds = default.node_sound_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	}
})

minetest.register_craft({
	output = "farming:rose_water",
	recipe = {
		{"flowers:rose", "flowers:rose", "flowers:rose"},
		{"flowers:rose", "flowers:rose", "flowers:rose"},
		{"group:food_water_glass", "group:food_pot", "vessels:glass_bottle"}
	},
	replacements = {
		{"group:food_water_glass", "vessels:drinking_glass"},
		{"group:food_pot", "farming:pot"}
	}
})

--= Turkish Delight

minetest.register_craftitem("farming:turkish_delight", {
	description = S("Turkish Delight"),
	inventory_image = "farming_turkish_delight.png",
	groups = {flammable = 3, ch_food = 2},
	on_use = minetest.item_eat(2)
})

minetest.register_craft({
	output = "farming:turkish_delight 4",
	recipe = {
		{"group:food_gelatin", "group:food_sugar", "group:food_gelatin"},
		{"group:food_sugar", "group:food_rose_water", "group:food_sugar"},
		{"group:food_sugar", "dye:pink", "group:food_sugar"}
	},
	replacements = {
		{"group:food_cornstarch", "farming:bowl"},
		{"group:food_rose_water", "vessels:glass_bottle"}
	}
})

--= Garlic Bread

minetest.register_craftitem("farming:garlic_bread", {
	description = S("Garlic Bread"),
	inventory_image = "farming_garlic_bread.png",
	groups = {flammable = 3, ch_food = 2},
	on_use = minetest.item_eat(2)
})

minetest.register_craft({
	output = "farming:garlic_bread",
	recipe = {
		{"group:food_toast", "group:food_garlic_clove", "group:food_garlic_clove"}
	}
})

--= Donuts (thanks to Bockwurst for making the donut images)

minetest.register_craftitem("farming:donut", {
	description = S("Donut"),
	inventory_image = "farming_donut.png",
	on_use = minetest.item_eat(4),
	groups = {ch_food = 4},
})

minetest.register_craft({
	output = "farming:donut 3",
	recipe = {
		{"", "group:food_wheat", ""},
		{"group:food_wheat", "group:food_sugar", "group:food_wheat"},
		{"", "group:food_wheat", ""}
	}
})

minetest.register_craftitem("farming:donut_chocolate", {
	description = S("Chocolate Donut"),
	inventory_image = "farming_donut_chocolate.png",
	on_use = minetest.item_eat(6),
	groups = {ch_food = 6},
})

minetest.register_craft({
	output = "farming:donut_chocolate",
	recipe = {
		{"group:food_cocoa"},
		{"farming:donut"}
	}
})

minetest.register_craftitem("farming:donut_apple", {
	description = S("Apple Donut"),
	inventory_image = "farming_donut_apple.png",
	on_use = minetest.item_eat(6),
	groups = {ch_food = 6},
})

minetest.register_craft({
	output = "farming:donut_apple",
	recipe = {
		{"default:apple"},
		{"farming:donut"}
	}
})

--= Porridge Oats

minetest.register_craftitem("farming:porridge", {
	description = S("Porridge"),
	inventory_image = "farming_porridge.png",
	on_use = minetest.item_eat(6, "farming:bowl"),
	groups = {ch_food = 6},
})

minetest.register_craft({
	output = "farming:porridge",
	recipe = {
		{"group:food_oats", "group:food_oats", "group:food_oats"},
		{"group:food_oats", "group:food_bowl", "group:food_milk_glass"}
	},
	replacements = {
		{"mobs:glass_milk", "vessels:drinking_glass"},
		{"farming:soy_milk", "vessels:drinking_glass"}
	}
})

--= Jaffa Cake

minetest.register_craftitem("farming:jaffa_cake", {
	description = S("Jaffa Cake"),
	inventory_image = "farming_jaffa_cake.png",
	on_use = minetest.item_eat(6),
	groups = {ch_food = 6},
})

minetest.register_craft({
	output = "farming:jaffa_cake",
	recipe = {
		{"farming:baking_tray", "group:food_egg", "group:food_sugar"},
		{"group:food_flour", "group:food_cocoa", "group:food_orange"},
		{"group:food_milk", "", ""}
	},
	replacements = {
		{"farming:baking_tray", "farming:baking_tray"},
		{"mobs:bucket_milk", "bucket:bucket_empty"},
		{"mobs:wooden_bucket_milk", "wooden_bucket:bucket_wood_empty"},
		{"farming:soy_milk", "vessels:drining_glass"}
	}
})

-- Apple Pie

minetest.register_craftitem("farming:apple_pie", {
	description = S("Apple Pie"),
	inventory_image = "farming_apple_pie.png",
	on_use = minetest.item_eat(6),
	groups = {ch_food = 6},
})

minetest.register_craft({
	output = "farming:apple_pie",
	recipe = {
		{"group:food_flour", "group:food_sugar", "group:food_apple"},
		{"", "group:food_baking_tray", ""}
	},
	replacements = {{"group:food_baking_tray", "farming:baking_tray"}}
})

-- Cactus Juice

minetest.register_craftitem("farming:cactus_juice", {
	description = S("Cactus Juice"),
	inventory_image = "farming_cactus_juice.png",
	groups = {vessel = 1, drink = 1, ch_food = 2, ch_poison = 1},
	on_use = function(itemstack, user, pointed_thing)
		if user then
			if math.random(5) == 1 then
				return minetest.do_item_eat(-1, "vessels:drinking_glass",
						itemstack, user, pointed_thing)
			else
				return minetest.do_item_eat(2, "vessels:drinking_glass",
						itemstack, user, pointed_thing)
			end
		end
	end
})

minetest.register_craft({
	output = "farming:cactus_juice",
	recipe = {
		{"default:cactus"},
		{"farming:juicer"},
		{"vessels:drinking_glass"}
	},
	replacements = {
		{"group:food_juicer", "farming:juicer"}
	}
})

-- Pasta

minetest.register_craftitem("farming:pasta", {
	description = S("Pasta"),
	inventory_image = "farming_pasta.png",
	groups = {food_pasta = 1}
})

minetest.register_craft({
	output = "farming:pasta",
	recipe = {
		{"group:food_flour", "group:food_butter", "group:food_mixing_bowl"}
	},
	replacements = {{"group:food_mixing_bowl", "farming:mixing_bowl"}}
})

minetest.register_craft({
	output = "farming:pasta",
	recipe = {
		{"group:food_flour", "group:food_oil", "group:food_mixing_bowl"}
	},
	replacements = {
		{"group:food_mixing_bowl", "farming:mixing_bowl"},
		{"group:food_oil", "vessels:glass_bottle"}
	}
})

-- Spaghetti

minetest.register_craftitem("farming:spaghetti", {
	description = S("Spaghetti"),
	inventory_image = "farming_spaghetti.png",
	on_use = minetest.item_eat(8),
	groups = {ch_food = 8},
})

minetest.register_craft({
	output = "farming:spaghetti",
	recipe = {
		{"group:food_pasta", "group:food_saucepan", "group:food_tomato"},
		{"group:food_garlic_clove", "group:food_garlic_clove", ""}
	},
	replacements = {{"group:food_saucepan", "farming:saucepan"}}
})

-- Korean Bibimbap

minetest.register_craftitem("farming:bibimbap", {
	description = S("Bibimbap"),
	inventory_image = "farming_bibimbap.png",
	on_use = minetest.item_eat(8, "farming:bowl"),
	groups = {ch_food = 8},
})

minetest.register_craft({
	output = "farming:bibimbap",
	recipe = {
		{"group:food_skillet", "group:food_bowl", "group:food_egg"},
		{"group:food_rice", "group:food_chicken_raw", "group:food_cabbage"},
		{"group:food_carrot", "group:food_chili_pepper", ""}
	},
	replacements = {{"group:food_skillet", "farming:skillet"}}
})

minetest.register_craft({
	output = "farming:bibimbap",
	type = "shapeless",
	recipe = {
		"group:food_skillet", "group:food_bowl", "group:food_mushroom",
		"group:food_rice", "group:food_cabbage", "group:food_carrot",
		"group:food_mushroom", "group:food_chili_pepper"
	},
	replacements = {{"group:food_skillet", "farming:skillet"}}
})

-- Burger

minetest.register_craftitem("farming:burger", {
	description = S("Burger"),
	inventory_image = "farming_burger.png",
	on_use = minetest.item_eat(16),
	groups = {ch_food = 16},
})

minetest.register_craft({
	output = "farming:burger",
	recipe = {
		{"farming:bread", "group:food_meat", "group:food_cheese"},
		{"group:food_tomato", "group:food_cucumber", "group:food_onion"},
		{"group:food_lettuce", "", ""}
	}
})

-- Salad

minetest.register_craftitem("farming:salad", {
	description = S("Salad"),
	inventory_image = "farming_salad.png",
	on_use = minetest.item_eat(8, "farming:bowl"),
	groups = {ch_food = 8},
})

minetest.register_craft({
	output = "farming:salad",
	type = "shapeless",
	recipe = {
		"group:food_bowl", "group:food_tomato", "group:food_cucumber",
		"group:food_lettuce", "group:food_oil"
	}
})

-- Triple Berry Smoothie

minetest.register_craftitem("farming:smoothie_berry", {
	description = S("Triple Berry Smoothie"),
	inventory_image = "farming_berry_smoothie.png",
	on_use = minetest.item_eat(6, "vessels:drinking_glass"),
	groups = {vessel = 1, drink = 6}
})

minetest.register_craft({
	output = "farming:smoothie_berry",
	type = "shapeless",
	recipe = {
		"group:food_raspberries", "group:food_blackberries",
		"group:food_strawberry", "group:food_banana",
		"vessels:drinking_glass"
	}
})

-- Patatas a la importancia

minetest.register_craftitem("farming:spanish_potatoes", {
	description = S("Spanish Potatoes"),
	inventory_image = "farming_spanish_potatoes.png",
	on_use = minetest.item_eat(8, "farming:bowl"),
	groups = {ch_food = 8},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:spanish_potatoes",
	recipe = {
		"farming:potato", "group:food_parsley", "farming:potato",
		"group:food_egg", "group:food_flour", "farming:onion",
		"farming:garlic_clove", "group:food_bowl", "group:food_skillet"
	},
	replacements = {{"group:food_skillet", "farming:skillet"}}
})

-- Potato omelet

minetest.register_craftitem("farming:potato_omelet", {
	description = S("Potato omelet"),
	inventory_image = "farming_potato_omelet.png",
	on_use = minetest.item_eat(6, "farming:bowl"),
	groups = {ch_food = 6},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:potato_omelet",
	recipe = {
		"group:food_egg", "farming:potato", "group:food_onion",
		"group:food_skillet", "group:food_bowl"},
	replacements = {{"group:food_skillet", "farming:skillet"}}
})

-- Paella

minetest.register_craftitem("farming:paella", {
	description = S("Paella"),
	inventory_image = "farming_paella.png",
	on_use = minetest.item_eat(8, "farming:bowl"),
	groups = {ch_food = 8},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:paella",
	recipe = {
		"group:food_rice", "dye:orange", "farming:pepper_red",
		"group:food_peas", "group:food_chicken", "group:food_bowl", "group:food_skillet"
	},
	replacements = {{"group:food_skillet", "farming:skillet"}}
})

-- Flan

minetest.register_craftitem("farming:flan", {
	description = S("Vanilla Flan"),
	inventory_image = "farming_vanilla_flan.png",
	on_use = minetest.item_eat(6),
	groups = {ch_food = 6},
})

minetest.register_craft({
	output = "farming:flan",
	recipe = {
		{"group:food_sugar", "group:food_milk", "farming:caramel"},
		{"group:food_egg", "group:food_egg", "farming:vanilla_extract"}
	},
	replacements = {
		{"cucina_vegana:soy_milk", "vessels:drinking_glass"},
		{"mobs:bucket_milk", "bucket:bucket_empty"},
		{"mobs:wooden_bucket_milk", "wooden_bucket:bucket_wood_empty"},
		{"farming:vanilla_extract", "vessels:glass_bottle"}
	}
})

-- Vegan Cheese

minetest.register_craftitem("farming:cheese_vegan", {
	description = S("Vegan Cheese"),
	inventory_image = "farming_cheese_vegan.png",
	on_use = minetest.item_eat(2),
	groups = {food_cheese = 1, flammable = 2, ch_food = 2}
})


minetest.register_craft({
	output = "farming:cheese_vegan",
	recipe = {
		{"farming:soy_milk", "farming:soy_milk", "farming:soy_milk"},
		{"group:food_salt", "group:food_peppercorn", "farming:bottle_ethanol"},
		{"group:food_gelatin", "group:food_pot", ""}
	},
	replacements = {
		{"farming:soy_milk", "vessels:drinking_glass 3"},
		{"farming:pot", "farming:pot"},
		{"farming:bottle_ethanol", "vessels:glass_bottle"}
	}
})

minetest.register_craft({
	output = "farming:cheese_vegan",
	recipe = {
		{"farming:soy_milk", "farming:soy_milk", "farming:soy_milk"},
		{"group:food_salt", "group:food_peppercorn", "group:food_lemon"},
		{"group:food_gelatin", "group:food_pot", ""}
	},
	replacements = {
		{"farming:soy_milk", "vessels:drinking_glass 3"},
		{"farming:pot", "farming:pot"}
	}
})

-- Onigiri

minetest.register_craftitem("farming:onigiri", {
	description = S("Onirigi"),
	inventory_image = "farming_onigiri.png",
	on_use = minetest.item_eat(2),
	groups = {flammable = 2, ch_food = 2}
})

minetest.register_craft({
	output = "farming:onigiri",
	recipe = {
		{"group:food_rice", "group:food_salt", "group:food_rice"},
		{"", "group:food_seaweed", ""}
	}
})

-- Gyoza

minetest.register_craftitem("farming:gyoza", {
	description = S("Gyoza"),
	inventory_image = "farming_gyoza.png",
	on_use = minetest.item_eat(4),
	groups = {flammable = 2, ch_food = 4}
})

minetest.register_craft({
	output = "farming:gyoza 4",
	recipe = {
		{"group:food_cabbage", "group:food_garlic_clove", "group:food_onion"},
		{"group:food_meat_raw", "group:food_salt", "group:food_flour"},
		{"", "group:food_skillet", ""}

	},
	replacements = {
		{"group:food_skillet", "farming:skillet"}
	}
})

-- Mochi

minetest.register_craftitem("farming:mochi", {
	description = S("Mochi"),
	inventory_image = "farming_mochi.png",
	on_use = minetest.item_eat(3),
	groups = {flammable = 2, ch_food = 3}
})

minetest.register_craft({
	output = "farming:mochi",
	recipe = {
		{"group:food_rice", "group:food_sugar", "group:food_rice"},
		{"", "group:food_mortar_pestle", ""},
		{"", "farming:glass_water", ""}
	},
	replacements = {
		{"group:food_mortar_pestle", "farming:mortar_pestle"},
		{"farming:glass_water", "vessels:drinking_glass"}
	}
})
