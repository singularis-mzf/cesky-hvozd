
-- craft bones from animalmaterials into bonemeal
if minetest.get_modpath("animalmaterials") then

	minetest.register_craft({
		output = "bonemeal:bonemeal 2",
		recipe = {{"animalmaterials:bone"}}
	})
end


if farming and farming.mod and farming.mod == "redo" then

	bonemeal:add_crop({
		{"farming:tomato_", 8},
		{"farming:corn_", 8},
		{"farming:melon_", 8},
		{"farming:pumpkin_", 8},
		{"farming:beanpole_", 5},
		{"farming:blueberry_", 4},
		{"farming:raspberry_", 4},
		{"farming:carrot_", 8},
		{"farming:cocoa_", 4},
		{"farming:coffee_", 5},
		{"farming:cucumber_", 4},
		{"farming:potato_", 4},
		{"farming:grapes_", 8},
		{"farming:rhubarb_", 3},
		{"farming:barley_", 7},
		{"farming:hemp_", 8},
		{"farming:chili_", 8},
		{"farming:garlic_", 5},
		{"farming:onion_", 5},
		{"farming:pepper_", 7},
		{"farming:pineapple_", 8},
		{"farming:pea_", 5},
		{"farming:beetroot_", 5},
		{"farming:rye_", 8},
		{"farming:oat_", 8},
		{"farming:rice_", 8},
		{"farming:mint_", 4},
		{"farming:cabbage_", 6},
		{"farming:lettuce_", 5},
		{"farming:blackberry_", 4},
		{"farming:vanilla_", 8},
		{"farming:soy_", 7},
		{"farming:artichoke_", 5},
		{"farming:parsley_", 3},
		{"farming:sunflower_", 8},
		{"farming:strawberry_", 8},
		{"farming:flax_", 6},
		{"farming:banana_", 8},
		{"farming:asparagus_", 5},
		{"farming:eggplant_", 4},
		{"farming:spinach_", 4},
		{"farming:chives_", 5},
		{"farming:kohlrabi_", 6},
		{"farming:rosemary_", 6},
	})
end


if minetest.get_modpath("ethereal") then

	bonemeal:add_crop({
		{"ethereal:strawberry_", 8},
		{"ethereal:onion_", 5}
	})

	bonemeal:add_sapling({
		{"ethereal:palm_sapling", ethereal.grow_palm_tree, "soil"},
		{"ethereal:palm_sapling", ethereal.grow_palm_tree, "sand"},
		{"ethereal:yellow_tree_sapling", ethereal.grow_yellow_tree, "soil"},
		{"ethereal:big_tree_sapling", ethereal.grow_big_tree, "soil"},
		{"ethereal:banana_tree_sapling", ethereal.grow_banana_tree, "soil"},
		{"ethereal:frost_tree_sapling", ethereal.grow_frost_tree, "soil"},
		{"ethereal:mushroom_sapling", ethereal.grow_mushroom_tree, "soil"},
		{"ethereal:willow_sapling", ethereal.grow_willow_tree, "soil"},
		{"ethereal:redwood_sapling", ethereal.grow_redwood_tree, "soil"},
		{"ethereal:giant_redwood_sapling", ethereal.grow_giant_redwood_tree, "soil"},
		{"ethereal:orange_tree_sapling", ethereal.grow_orange_tree, "soil"},
		{"ethereal:bamboo_sprout", ethereal.grow_bamboo_tree, "soil"},
		{"ethereal:birch_sapling", ethereal.grow_birch_tree, "soil"},
		{"ethereal:sakura_sapling", ethereal.grow_sakura_tree, "soil"},
		{"ethereal:lemon_tree_sapling", ethereal.grow_lemon_tree, "soil"},
		{"ethereal:olive_tree_sapling", ethereal.grow_olive_tree, "soil"}
	})

	local grass = {"default:grass_3", "default:grass_4", "default:grass_5", ""}

	bonemeal:add_deco({
		{"ethereal:crystal_dirt", {"ethereal:crystalgrass", "", "", "", ""}, {}},
		{"ethereal:fiery_dirt", {"ethereal:dry_shrub", "", "", "", ""}, {}},
		{"ethereal:prairie_dirt", grass, {"flowers:dandelion_white",
			"flowers:dandelion_yellow", "flowers:geranium", "flowers:rose",
			"flowers:tulip", "flowers:viola", "ethereal:strawberry_7"}},
		{"ethereal:gray_dirt", {}, {"ethereal:snowygrass", "", ""}},
		{"ethereal:cold_dirt", {}, {"ethereal:snowygrass", "", ""}},
		{"ethereal:mushroom_dirt", {}, {"flowers:mushroom_red", "flowers:mushroom_brown", "", "", ""}},
		{"ethereal:jungle_dirt", grass, {"default:junglegrass", "", "", ""}},
		{"ethereal:grove_dirt", grass, {"ethereal:fern", "", "", ""}},
		{"ethereal:bamboo_dirt", grass, {}}
	})
end


if minetest.get_modpath("moretrees") then

	-- special fir check for snow
	local function fir_grow(pos)

		if minetest.find_node_near(pos, 1,
			{"default:snow", "default:snowblock", "default:dirt_with_snow"}) then

			moretrees.grow_fir_snow(pos)
		else
			moretrees.grow_fir(pos)
		end
	end

	bonemeal:add_sapling({
		{"moretrees:beech_sapling", moretrees.beech_model, "soil"},
		{"moretrees:apple_tree_sapling", moretrees.apple_tree_model, "soil"},
		{"moretrees:oak_sapling", moretrees.oak_model, "soil"},
		{"moretrees:sequoia_sapling", moretrees.sequoia_model, "soil"},
		{"moretrees:birch_sapling", moretrees.grow_birch, "soil"},
		{"moretrees:palm_sapling", moretrees.palm_model, "soil"},
		{"moretrees:palm_sapling", moretrees.palm_model, "sand"},
		{"moretrees:date_palm_sapling", moretrees.date_palm_model, "soil"},
		{"moretrees:date_palm_sapling", moretrees.date_palm_model, "sand"},
		{"moretrees:spruce_sapling", moretrees.grow_spruce, "soil"},
		{"moretrees:cedar_sapling", moretrees.cedar_model, "soil"},
		{"moretrees:poplar_sapling", moretrees.poplar_model, "soil"},
		{"moretrees:willow_sapling", moretrees.willow_model, "soil"},
		{"moretrees:rubber_tree_sapling", moretrees.rubber_tree_model, "soil"},
		{"moretrees:fir_sapling", fir_grow, "soil"},

		{"moretrees:beech_sapling_ongen", moretrees.beech_model, "soil"},
		{"moretrees:apple_tree_sapling_ongen", moretrees.apple_tree_model, "soil"},
		{"moretrees:oak_sapling_ongen", moretrees.oak_model, "soil"},
		{"moretrees:sequoia_sapling_ongen", moretrees.sequoia_model, "soil"},
		{"moretrees:birch_sapling_ongen", moretrees.grow_birch, "soil"},
		{"moretrees:palm_sapling_ongen", moretrees.palm_model, "soil"},
		{"moretrees:palm_sapling_ongen", moretrees.palm_model, "sand"},
		{"moretrees:date_palm_sapling_ongen", moretrees.date_palm_model, "soil"},
		{"moretrees:date_palm_sapling_ongen", moretrees.date_palm_model, "sand"},
		{"moretrees:spruce_sapling_ongen", moretrees.grow_spruce, "soil"},
		{"moretrees:cedar_sapling_ongen", moretrees.cedar_model, "soil"},
		{"moretrees:poplar_sapling_ongen", moretrees.poplar_model, "soil"},
		{"moretrees:willow_sapling_ongen", moretrees.willow_model, "soil"},
		{"moretrees:rubber_tree_sapling_ongen", moretrees.rubber_tree_model, "soil"},
		{"moretrees:fir_sapling_ongen", fir_grow, "soil"},
	})

elseif minetest.get_modpath("technic_worldgen") then

	bonemeal:add_sapling({
		{"moretrees:rubber_tree_sapling", technic.rubber_tree_model, "soil"}
	})
end

if minetest.get_modpath("caverealms") then

	local fil = minetest.get_modpath("caverealms") .. "/schematics/shroom.mts"
	local add_shroom = function(pos)

		minetest.swap_node(pos, {name = "air"})

		minetest.place_schematic(
			{x = pos.x - 5, y = pos.y, z = pos.z - 5}, fil, 0, nil, false)
	end

	bonemeal:add_sapling({
		{"caverealms:mushroom_sapling", add_shroom, "soil"}
	})
end


local function y_func(grow_func)
	return function(pos)
		grow_func({x = pos.x, y = pos.y - 1, z = pos.z})
	end
end

if minetest.get_modpath("ferns") then

	bonemeal:add_sapling({
		{"ferns:sapling_giant_tree_fern", y_func(abstract_ferns.grow_giant_tree_fern), "soil"},
		{"ferns:sapling_giant_tree_fern", y_func(abstract_ferns.grow_giant_tree_fern), "sand"},
		{"ferns:sapling_tree_fern", y_func(abstract_ferns.grow_tree_fern), "soil"}
	})
end

if minetest.get_modpath("dryplants") then

	bonemeal:add_sapling({
		{"dryplants:reedmace_sapling", y_func(abstract_dryplants.grow_reedmace), "soil"}
	})
end


if minetest.get_modpath("dye") then

	local bonemeal_dyes = {
			bonemeal = "white", fertiliser = "green", mulch = "brown"}

	for mat, dye in pairs(bonemeal_dyes) do

		minetest.register_craft({
			output = "dye:" .. dye .. " 4",
			recipe = {
				{"bonemeal:" .. mat}
			},
		})
	end
end
