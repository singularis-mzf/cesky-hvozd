--   *******************************************
--   *****                 Crafts          *****
--   *******************************************

-- blueberry_pot
minetest.register_craft({
	output = "cucina_vegana:blueberry_pot",
	recipe = {	{"group:food_sugar", "default:stick", "group:food_sugar"},
				{"cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree"},
                {"", "bucket:bucket_water", ""}
			},
    replacements = {
                    {"default:stick", "default:stick"}
                   }
})

minetest.register_craft({
	output = "cucina_vegana:blueberry_pot",
	recipe = {	{"group:food_sugar", "default:stick", "group:food_sugar"},
				{"cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree"},
                {"", "bucket:bucket_river_water", ""}
			},
    replacements = {
                    {"default:stick", "default:stick"}
                   }
})

minetest.register_craft({
	output = "cucina_vegana:blueberry_pot",
	recipe = {	{"cucina_vegana:molasses", "default:stick", "cucina_vegana:molasses"},
				{"cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree"},
                {"", "bucket:bucket_water", ""}
			},
    replacements = {
                        {"default:stick", "default:stick"},
                        {"cucina_vegana:molasses", "vessels:drinking_glass 2"}
                   }
})

minetest.register_craft({
	output = "cucina_vegana:blueberry_pot",
	recipe = {	{"cucina_vegana:molasses", "default:stick", "cucina_vegana:molasses"},
				{"cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree", "cucina_vegana:blueberry_puree"},
                {"", "bucket:bucket_river_water", ""}
			},
    replacements = {
                        {"default:stick", "default:stick"},
                        {"cucina_vegana:molasses", "vessels:drinking_glass 2"}
                   }
})

-- ciabatta_dough
minetest.register_craft({
	output = "cucina_vegana:ciabatta_dough",
	recipe = {	{"cucina_vegana:soy_milk", "cucina_vegana:sunflower_seeds_oil", ""},
				{"group:food_flour", "cucina_vegana:rosemary", ""}
			},
    replacements = {
                        {"cucina_vegana:soy_milk", "vessels:drinking_glass"},
                        {"cucina_vegana:sunflower_seeds_oil", "vessels:glass_bottle"},
                    }
})

-- edamame
minetest.register_craft({
	output = "cucina_vegana:edamame",
	recipe = {	{"cucina_vegana:rosemary", "farming:soy_pod", "sandwiches:peanuts"},
                {"farming:soy_pod", "farming:soy_pod", "farming:soy_pod"},
				{"", "group:food_plate", ""}
			}
})

-- asparagus_hollandaise
minetest.register_craft({
	output = "cucina_vegana:asparagus_hollandaise",
	recipe = {	{"cucina_vegana:asparagus", "cucina_vegana:sauce_hollandaise", "cucina_vegana:parsley"},
				{"", "group:food_plate", ""}
			},
			replacements = {	{"group:food_sauce", "vessels:glass_bottle"},
						}
})

-- asparagus_rice
minetest.register_craft({
	output = "cucina_vegana:asparagus_rice",
	recipe = {
				{"cucina_vegana:asparagus", "group:food_rice", "group:food_butter"},
				{"", "group:food_plate", ""}
			},
			replacements = {
							{"group:food_rice", "cucina_vegana:bowl"},
						}
})

-- asparagus_soup
minetest.register_craft({
	output = "cucina_vegana:asparagus_soup",
	recipe = {	{"cucina_vegana:chives", "group:food_oil", "cucina_vegana:asparagus"},
				{"", "cucina_vegana:soy_milk", ""},
				{"", "group:food_plate", ""}
			},
			replacements = {{"group:food_milk", "vessels:glass_bottle"},
						   {"group:food_oil", "vessels:glass_bottle"},
						}
})

minetest.register_craft({
	output = "cucina_vegana:imitation_butter",
	recipe = {
		{"dye:yellow", "farming:soy_milk",  "farming:soy_milk"},
		{"", "", ""},
		{"", "", ""},
	},
	replacements = {{"farming:soy_milk", "vessels:drinking_glass 2"}}
})

-- proč tento recept nefunguje?
minetest.register_craft({
	output = "cucina_vegana:imitation_cheese",
	recipe = {
		{"dye:orange","cucina_vegana:imitation_butter", "cucina_vegana:imitation_butter"},
		{"", "", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "cucina_vegana:imitation_fish",
	recipe = {
				{"dye:blue","cucina_vegana:tofu", "dye:blue"},
				{"cucina_vegana:tofu","cucina_vegana:tofu", "cucina_vegana:tofu"},
				{"","cucina_vegana:tofu", ""},

			},
})

minetest.register_craft({
	output = "cucina_vegana:imitation_meat",
	recipe = {	{"dye:red", "cucina_vegana:tofu", "dye:white"},
				{"", "cucina_vegana:tofu", ""},
				{"", "cucina_vegana:tofu", ""}
			},
})

minetest.register_craft({
	output = "cucina_vegana:imitation_poultry",
	recipe = {	{"cucina_vegana:tofu", "", "dye:yellow"},
				{"", "cucina_vegana:tofu", ""},
				{"cucina_vegana:tofu", "cucina_vegana:tofu", "cucina_vegana:tofu"}
			},
})

minetest.register_craft({
	output = "cucina_vegana:sauce_hollandaise",
	recipe = {	{"cucina_vegana:parsley", "group:food_butter", "cucina_vegana:rosemary"},
				{"", "cucina_vegana:soy_milk", ""},
				{"", "vessels:glass_bottle", ""}
			},
    replacements = {
            {"cucina_vegana:soy_milk", "vessels:glass_bottle"}
                   }
})

-- bowl_rice
local buckets = {
	["bucket:bucket_water"] = "bucket:bucket_empty",
	["bucket:bucket_river_water"] = "bucket:bucket_empty",
	["bucket_wooden:bucket_water"] = "bucket_wooden:bucket_empty",
	["bucket_wooden:bucket_river_water"] = "bucket_wooden:bucket_empty",
}

for full_bucket, empty_bucket in pairs(buckets) do
	minetest.register_craft({
		output = "cucina_vegana:bowl_rice",
		recipe = {
			{"cucina_vegana:rice", "", ""},
			{full_bucket, "", ""},
			{"farming:mixing_bowl", "", ""},
		}, replacements = {{full_bucket, empty_bucket}}
	})
end

-- cucumber_in_glass
minetest.register_craft({
	output = "cucina_vegana:cucumber_in_glass",
	type = "shapeless",
	recipe = {"vessels:glass_bottle", "farming:cucumber", "farming:cucumber", "farming:cucumber"},
})

-- dandelion_honey
minetest.register_craft({
	output = "cucina_vegana:dandelion_honey",
	recipe = {	{"cucina_vegana:dandelion_suds_cooking", "", ""},
                {"group:wool", "", ""},
				{"vessels:glass_bottle", "", ""}
			},
    replacements = {
            {"cucina_vegana:dandelion_suds_cooking", "bucket:bucket_empty"},
            {"group:wool", "farming:cotton 2"}
                   }
})

-- pizza_funghi_raw
minetest.register_craft({
	output = "cucina_vegana:pizza_funghi_raw",
	recipe = {	{"", "group:food_oil", ""},
				{"flowers:mushroom_brown", "cucina_vegana:rosemary", "flowers:mushroom_brown"},
                {"", "group:pizza_dough", ""}
			},
    replacements = {{"group:food_oil", "vessels:glass_bottle"}}
})

-- fish_parsley_rosemary
minetest.register_craft({
	output = "cucina_vegana:fish_parsley_rosemary",
	recipe = {
				{"cucina_vegana:parsley","group:food_oil", "cucina_vegana:rosemary"},
				{"","group:food_fish", ""},
				{"","group:food_plate", ""},
			},
			replacements = {
							{"group:food_oil", "vessels:glass_bottle"},
						}
})

-- rice_starch
for full_bucket, empty_bucket in pairs(buckets) do
	minetest.register_craft({
		output = "cucina_vegana:rice_starch 2",
		recipe = {	{"wool:white", "cucina_vegana:rice", "wool:white"},
					{"wool:white", "cucina_vegana:rice", "wool:white"},
					{"", full_bucket, ""}
		}, replacements = {{"wool:white", "wool:white"}, {full_bucket, empty_bucket}}
	})
end

-- salad_hollandaise
minetest.register_craft({
	output = "cucina_vegana:salad_hollandaise",
	recipe = {
		{"cucina_vegana:sauce_hollandaise", "cucina_vegana:salad_bowl", ""},
		{"", "", ""},
		{"", "", ""},
	}, replacements = {{"cucina_vegana:sauce_hollandaise", "vessels:glass_bottle"}}
})

minetest.register_craft({
	output = "cucina_vegana:salad_hollandaise",
	recipe = {	{"cucina_vegana:parsley", "cucina_vegana:lettuce", "cucina_vegana:chives"},
				{"cucina_vegana:sauce_hollandaise", "group:food_oil", ""},
				{"", "farming:mixing_bowl", ""}
			},
    replacements = {
                {"group:food_oil", "vessels:glass_bottle"},
				{"cucina_vegana:sauce_hollandaise", "vessels:glass_bottle"}
	}
})

-- tofu_chives_rosemary
minetest.register_craft({
	output = "cucina_vegana:tofu_chives_rosemary",
	recipe = {	{"cucina_vegana:chives", "", "cucina_vegana:rosemary"},
				{"", "cucina_vegana:tofu", ""},
				{"", "group:food_plate", ""}
			},
})

-- vegan_strawberry_milk
minetest.register_craft({
	output = "cucina_vegana:vegan_strawberry_milk",
	recipe = {
		{"cucina_vegana:strawberry", "default:stick", "cucina_vegana:strawberry"},
		{"cucina_vegana:strawberry", "cucina_vegana:strawberry", "cucina_vegana:strawberry"},
		{"", "cucina_vegana:soy_milk", ""},
	}, replacements = {{"default:stick", "default:stick"}}
})

minetest.register_craft({
	output = "cucina_vegana:vegan_strawberry_milk",
	recipe = {
		{"group:food_strawberry", "default:stick", "group:food_strawberry"},
		{"group:food_strawberry", "group:food_strawberry", "group:food_strawberry"},
		{"", "cucina_vegana:soy_milk", ""},
		},
	replacements = {{"default:stick", "default:stick"}}
})

-- vegan_sushi
minetest.register_craft({
	output = "cucina_vegana:vegan_sushi",
	recipe = {
		{"group:food_fish", "cucina_vegana:bowl_rice", ""},
		{"default:papyrus", "", ""},
		{"", "", ""},
	},
	replacements = {
		{"cucina_vegana:bowl_rice", "cucina_vegana:bowl"}
	}
})

-- salad_bowl
minetest.register_craft({
	output = "cucina_vegana:salad_bowl",
	recipe = {
		{"cucina_vegana:parsley", "cucina_vegana:lettuce", "cucina_vegana:chives"},
		{"", "group:food_oil", ""},
		{"", "farming:mixing_bowl", ""}
	}, replacements = {{"group:food_oil", "vessels:glass_bottle"}}
})

-- pizza_vegana_raw
minetest.register_craft({
	output = "cucina_vegana:pizza_vegana_raw",
	recipe = {	{"", "cucina_vegana:sauce_hollandaise", ""},
				{"cucina_vegana:asparagus", "cucina_vegana:lettuce", "cucina_vegana:rosemary"},
                {"", "group:pizza_dough", ""}
			},
    replacements = {
                        {"cucina_vegana:sauce_hollandaise", "vessels:glass_bottle"},
                    }

})

-- kohlrabi_soup
for full_bucket, empty_bucket in pairs(buckets) do
	minetest.register_craft({
		output = "cucina_vegana:kohlrabi_soup",
		recipe = {	{"cucina_vegana:kohlrabi", "group:food_oil", "cucina_vegana:parsley"},
					{"", full_bucket, ""},
					{"", "farming:mixing_bowl", ""}
				},
				replacements = {{full_bucket, empty_bucket}, {"group:food_oil", "vessels:glass_bottle"}}
	})
end

-- sea_salad
for full_bucket, empty_bucket in pairs(buckets) do
	minetest.register_craft({
		output = "cucina_vegana:sea_salad",
		recipe = {	{"default:jungleleaves", "cucina_vegana:parsley", "cucina_vegana:lettuce"},
				{"cucina_vegana:chives", full_bucket, "cucina_vegana:asparagus"},
				{"", "farming:mixing_bowl", ""}
		}, replacements = {{full_bucket, empty_bucket}}
	})
end

-- dandelion_suds
for full_bucket, empty_bucket in pairs(buckets) do
	minetest.register_craft({
		output = "cucina_vegana:dandelion_suds",
		recipe = {
			{"flowers:dandelion_yellow", "flowers:dandelion_yellow", "flowers:dandelion_yellow"},
			{"flowers:dandelion_yellow", "flowers:dandelion_yellow", "flowers:dandelion_yellow"},
			{"", full_bucket, ""}
		}
	})
end

-- soy_soup
minetest.register_craft({
	output = "cucina_vegana:soy_soup",
	recipe = {	{"farming:chives", "group:food_oil", "farming:parsley"},
				{"", "farming:soy_milk", ""},
				{"", "group:food_plate", ""}
			},
			replacements = {{"group:food_milk", "vessels:glass_bottle"},
						   {"group:food_oil", "vessels:glass_bottle"},
						}
})

-- plate
minetest.register_craft({
	output = "cucina_vegana:plate 8",
	recipe = {
		{"group:bakedclay", "", "group:bakedclay"},
		{"", "group:bakedclay", ""},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "cucina_vegana:plate",
	recipe = {
		{"bakedclay:slab_baked_clay_white_1", "", "bakedclay:slab_baked_clay_white_1"},
		{"", "bakedclay:slab_baked_clay_white_1", ""},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "cucina_vegana:pizza_dough",
	recipe = {	{"group:food_milk", "group:food_oil", "group:food_cheese"},
				{"group:food_flour", "group:food_flour", "group:food_flour"}
			},
    replacements = {
                    {"group:food_milk", "vessels:glass_bottle"},
                    {"group:food_oil", "vessels:glass_bottle"},
                    }
})

minetest.register_craft({
	output = "cucina_vegana:sunflower_seeds_dough",
	recipe = {
		{"", "cucina_vegana:sunflower_seeds", ""},
		{"farming:flour", "farming:flour", "farming:flour"},
		{"", "", ""}
	}
})

minetest.register_craft({
	output = "cucina_vegana:sunflower_seeds_dough",
	recipe = {
		{"", "cucina_vegana:sunflower_seeds", ""},
		{"group:food_flour", "group:food_flour", "group:food_flour"},
		{"", "", ""},
	}
})
