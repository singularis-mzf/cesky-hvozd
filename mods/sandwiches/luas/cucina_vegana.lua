local S = minetest.get_translator("sandwiches")
local skillet = "sandwiches:skillet"
local mope = "sandwiches:mortar_pestle"
if minetest.global_exists("farming") and  farming.mod == "redo" then
  mope = "farming:mortar_pestle"
	skillet = "farming:skillet"
end

local asparagus = "farming:asparagus"
local chives = "farming:parsley"
local rosemary = "farming:parsley"
local sauce = "farming:soy_sauce"
local tofu_cooked = "farming:tofu_cooked"

-- SANDWICHES --

minetest.register_craftitem("sandwiches:tasty_asparagus_sandwich", {
	description = S("Tasty asparagus sandwich"),
	on_use = ch_core.item_eat("sandwiches:bread_crumbs"),
	groups = {food = 7, food_sandwich = 1,  food_vegan = 1, ch_food = 7},
	inventory_image = "tasty_asparagus_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:tasty_asparagus_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{asparagus, sauce, asparagus},
		{"", "sandwiches:bread_slice", ""},
	}
})

if sandwiches.ingredient_support.meat then

  minetest.register_craftitem("sandwiches:ham_and_asparagus_sandwich", {
  	description = S("Ham and asparagus sandwich"),
  	on_use = ch_core.item_eat("sandwiches:bread_crumbs"),
  	groups = {food = 7, food_sandwich = 1, ch_food = 7},
  	inventory_image = "ham_and_asparagus_sandwich.png"
  })
  minetest.register_craft({
  	output = "sandwiches:ham_and_asparagus_sandwich",
  	recipe = {
  		{"", "sandwiches:bread_slice", ""},
  		{asparagus, "group:food_ham" ,asparagus},
  		{"", "sandwiches:bread_slice", ""},
  	}
  })

  minetest.register_craftitem("sandwiches:club_sandwich", {
  	description = S("Club sandwich"),
  	on_use = ch_core.item_eat("sandwiches:bread_crumbs"),
  	groups = {food = 18, food_sandwich = 1, ch_food = 18},
  	inventory_image = "club_sandwich.png"
  })
  minetest.register_craft({
  	output = "sandwiches:club_sandwich",
  	recipe = {
  		{"sandwiches:bread_slice", "group:food_tomato" , "sandwiches:bread_slice"},
  		{"sandwiches:chicken_strips", sauce ,"group:food_bacon" },
  		{"sandwiches:bread_slice", "group:food_lettuce", "sandwiches:bread_slice"},
  	}
  })


end -- if ham is present

minetest.register_craftitem("sandwiches:tasty_tofu_sandwich", {
	description = S("Tofu and asparagus sandwich"),
	on_use = ch_core.item_eat("sandwiches:bread_crumbs"),
	groups = {food = 8, food_sandwich = 1, food_vegan = 1, ch_food = 8},
	inventory_image = "tasty_tofu_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:tasty_tofu_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{asparagus, "cucina_vegana:tofu_cooked" ,asparagus},
		{"", "sandwiches:bread_slice", ""},
	}
})
minetest.register_craft({
	output = "sandwiches:tasty_tofu_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{asparagus, "farming:tofu_cooked" ,asparagus},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craftitem("sandwiches:tofu_sandwich", {
	description = S("Tofu sandwich"),
	on_use = ch_core.item_eat("sandwiches:bread_crumbs"),
	groups = {food = 7, food_sandwich = 1,  food_vegan = 1, ch_food = 7},
	inventory_image = "tofu_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:tofu_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"cucina_vegana:tofu_cooked", "cucina_vegana:tofu_cooked", "cucina_vegana:tofu_cooked"},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craftitem("sandwiches:gourmet_sandwich", {
	description = S("Gourmet sandwich"),
	on_use = ch_core.item_eat("sandwiches:bread_crumbs"),
	groups = {food = 12, food_sandwich = 1, ch_food = 12},
	inventory_image = "gourmet_vegan_sandwich.png"
})
minetest.register_alias("sandwiches:gourmet_meat_sandwich", "sandwiches:gourmet_sandwich")
minetest.register_alias("sandwiches:gourmet_vegan_sandwich", "sandwiches:gourmet_sandwich")

minetest.register_craft({
  output = "sandwiches:gourmet_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {chives, "group:food_ham" ,sauce },
    {"", "sandwiches:bread_slice", ""},
  }
})
minetest.register_craft({
  output = "sandwiches:gourmet_sandwich",
  recipe = {
    {"", "sandwiches:bread_slice", ""},
    {chives, "group:food_chicken_strips" ,sauce },
    {"", "sandwiches:bread_slice", ""},
  }
})
minetest.register_craft({
	output = "sandwiches:gourmet_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{chives, "cucina_vegana:tofu_cooked" ,sauce },
		{"", "sandwiches:bread_slice", ""},
	}
})
minetest.register_craft({
	output = "sandwiches:gourmet_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{chives, "farming:tofu_cooked" ,sauce },
		{"", "sandwiches:bread_slice", ""},
	}
})
minetest.register_craft({
	output = "sandwiches:gourmet_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{chives, "cucina_vegana:imitation_meat" ,sauce },
		{"", "sandwiches:bread_slice", ""},
	}
})
minetest.register_craft({
	output = "sandwiches:gourmet_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{chives, "cucina_vegana:imitation_poultry" ,sauce },
		{"", "sandwiches:bread_slice", ""},
	}
})

-- ALREADY EXISTING SANDWICHES CRAFT --

minetest.register_craft({
	output = "sandwiches:classic_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"group:food_lettuce", "cucina_vegana:tofu_cooked", "group:food_tomato" },
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craft({
	output = "sandwiches:hot_veggie_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{asparagus, "sandwiches:tabasco", "group:food_lettuce"},
		{"", "sandwiches:bread_slice", ""},
	},
	replacements = {{"sandwiches:tabasco", "vessels:glass_bottle"},}
})

minetest.register_craft({
		output = "sandwiches:fancy_garlic_sandwich",
		recipe = {
			{"", "sandwiches:garlic_bread", ""},
			{"cucina_vegana:tofu_cooked", "sandwiches:trifolat_mushrooms", "group:food_cheese"},
			{"", "sandwiches:garlic_bread", ""},
		},
})
minetest.register_craft({
		output = "sandwiches:fancy_garlic_sandwich",
		recipe = {
			{"", "sandwiches:garlic_bread", ""},
			{"farming:tofu_cooked", "sandwiches:trifolat_mushrooms", "group:food_cheese"},
			{"", "sandwiches:garlic_bread", ""},
		},
})

minetest.register_craft({
		output = "sandwiches:tasty_garlic_sandwich",
		recipe = {
			{"", "sandwiches:garlic_bread", ""},
			{"group:food_tomato", "cucina_vegana:tofu_cooked", "group:food_cheese"},
			{"", "sandwiches:garlic_bread", ""},
		},
})
minetest.register_craft({
		output = "sandwiches:tasty_garlic_sandwich",
		recipe = {
			{"", "sandwiches:garlic_bread", ""},
			{"group:food_tomato", "farming:tofu_cooked", "group:food_cheese"},
			{"", "sandwiches:garlic_bread", ""},
		},
})

--ALREADY EXISTING NON SANDWICH ITEMS

minetest.register_craft({
	output = "sandwiches:tabasco 3",
	type = "shapeless";
	recipe = {"group:food_chili", "group:food_chili", "group:food_chili",
			  "group:food_chili", "group:food_chili", "group:food_chili",
			  "group:food_mortar_pestle", "vessels:glass_bottle",
	},
	replacements = {{"group:food_mortar_pestle", mope }}
})

minetest.register_craft({
	output = "sandwiches:roasted_potatoes 5",
	type = "shapeless",
	recipe = {
		"group:food_potato", "group:food_potato",
		"group:food_skillet", "group:food_oil", rosemary,
	},
	replacements = {{"group:food_skillet", "farming:skillet"}, {"group:food_oil", "vessels:glass_bottle"}}
})

minetest.register_craft({
		output = "sandwiches:garlic_bread 4",
		recipe = {
			{"", "cucina_vegana:garlic", ""},
			{"sandwiches:bread_slice", "sandwiches:bread_slice", "sandwiches:bread_slice"},
			{"group:food_skillet", "sandwiches:bread_slice", "group:food_butter"},
		},
		replacements = {{"group:food_skillet", skillet}}
})

-- MOLASSES --

if minetest.registered_items["sandwiches:caramelized_onion"] then

	minetest.register_craft({
		output = "sandwiches:caramelized_onion 4",
		type = "shapeless";
		recipe = {"group:food_onion", "group:food_onion", "cucina_vegana:molasses", "group:food_skillet"},
		replacements = {{"group:food_skillet", "farming:skillet"}}
	})

end
