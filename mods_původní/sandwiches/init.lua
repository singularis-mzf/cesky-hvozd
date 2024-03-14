-- Mod: sandwiches

sandwiches = {}
sandwiches.version = 1.9 -- complete overhaul
sandwiches.path = minetest.get_modpath("sandwiches")

sandwiches.ingredient_support = {
  ["true"] = true, -- provided by this mod or its dependencies
  ["meat"] = false,
  ["veggie"] = false,
  ["berry"] = false,
  ["banana"] = false,
  ["choco"] = false,
  ["honey"] = minetest.get_modpath("bees") ~= nil or minetest.get_modpath("mobs_animal") ~= nil or minetest.get_modpath("xdecor") ~= nil,
  ["fish"] = false,
  ["mushroom"] =  minetest.get_modpath("flowers") ~= nil,
  ["dairy"] = minetest.get_modpath("mobs_animal") ~= nil,
  ["herbs"] = minetest.get_modpath("potted_farming") ~= nil,
}

-- for future improvements (need cuisine)
local pot = "sandwiches:pot" --jam and jelly
local skillet = "sandwiches:skillet" -- toasts and tasty veg
local board = "sandwiches:cutting_board" -- ham bacon chicken_strips
local mope = "sandwiches:mortar_pestle" -- tabasco
local mix = "sandwiches:mixing_bowl" --sprinkles
if minetest.global_exists("farming") and farming.mod == "redo" then
  pot = "farming:pot"
  skillet = "farming:skillet"
  board = "farming:cutting_board"
  mope = "farming:mortar_pestle"
  mix = "farming:mixing_bowl"

  sandwiches.ingredient_support.veggie = true
  sandwiches.ingredient_support.berry = true
  sandwiches.ingredient_support.choco = true

else
  dofile(sandwiches.path .. "/luas/tools.lua")
end

-- BREAD --

minetest.register_craftitem("sandwiches:bread_slice", {
    description = "Bread slice",
    on_use = minetest.item_eat(1),
    groups = {food = 1, food_bread_slice = 1, flammable = 1},
    inventory_image = "sandwiches_bread_slice.png"
})
minetest.register_craft({
	output = "sandwiches:bread_slice 8",
	type = "shapeless",
	recipe = {"group:food_bread", "group:food_cutting_board", "group:food_bread"},
  replacements = {  {"group:food_cutting_board", board }, }
})

minetest.register_craftitem("sandwiches:bread_crumbs", {
    description = "Bread crumbs",
    on_use = minetest.item_eat(1),
    groups = {food = 1, food_bread_crumbs = 1, flammable = 1},
    inventory_image = "bread_crumbs.png"
})
minetest.register_craft({
	output = "sandwiches:bread_crumbs 4",
	type = "shapeless",
	recipe = {"group:food_bread_slice"},
})

if minetest.get_modpath("animalia") or minetest.get_modpath("mobs") then
  if minetest.get_modpath("petz") then
    sandwiches.ingredient_support.honey = true
  end
  dofile(sandwiches.path .. "/luas/meat.lua")
  sandwiches.ingredient_support.meat = true
  sandwiches.ingredient_support.dairy = true
end
if minetest.get_modpath("cheese") then
  sandwiches.ingredient_support.dairy = true
end
if sandwiches.ingredient_support.meat and sandwiches.ingredient_support.dairy and sandwiches.ingredient_support.veggie then
  dofile(sandwiches.path .. "/luas/toasts.lua")
end
if minetest.get_modpath("cucina_vegana") then
  dofile(sandwiches.path .. "/luas/cucina_vegana.lua")
  sandwiches.ingredient_support.banana = true
  sandwiches.ingredient_support.veggie = true
  sandwiches.ingredient_support.banana = true
  sandwiches.ingredient_support.honey = true
end
if minetest.get_modpath("bbq") and sandwiches.ingredient_support.meat then
  dofile(sandwiches.path .. "/luas/bbq.lua")
end
if minetest.get_modpath("ethereal") then
  dofile(sandwiches.path .. "/luas/fish.lua")
  sandwiches.ingredient_support.fish = true
  sandwiches.ingredient_support.banana = true
  sandwiches.ingredient_support.berry = true
end
if minetest.get_modpath("agriculture") then
  dofile(sandwiches.path .. "/luas/agriculture.lua")
  sandwiches.ingredient_support.veggie = true
  sandwiches.ingredient_support.berry = true
end
if minetest.get_modpath("x_farming") then
  dofile(sandwiches.path .. "/luas/xfarming.lua")
  sandwiches.ingredient_support.veggie = true
  sandwiches.ingredient_support.berry = true
  sandwiches.ingredient_support.choco = true
end
if minetest.get_modpath("cacaotree") then
  sandwiches.ingredient_support.choco = true
end
if minetest.get_modpath("moretrees") and sandwiches.ingredient_support.choco then
  dofile(sandwiches.path .. "/luas/nutella.lua")
end


if minetest.get_modpath("bushes_classic") or sandwiches.ingredient_support.berry then

-- BREAD PUDDING --
  -- no jam, no bread pudding
  minetest.register_craftitem("sandwiches:sweet_bread_pudding_raw", {
    description = "Uncooked sweet bread pudding",
    groups = {food_sweet_bread = 1, flammable = 1},
    inventory_image = "sweet_bread_pudding_raw.png"
  })
  minetest.register_craftitem("sandwiches:sweet_bread_pudding", {
    description = "Sweet bread pudding",
    on_use = minetest.item_eat(10),
    groups = {food = 10, food_sweet_bread = 1, flammable = 1},
    inventory_image = "sweet_bread_pudding.png"
  })
  minetest.register_craft({
    output = "sandwiches:sweet_bread_pudding_raw",
    recipe = {
      {"sandwiches:bread_crumbs", "sandwiches:bread_crumbs", "sandwiches:bread_crumbs"},
      {"group:food_jam", "group:food_sugar", "group:food_jam"},
      {"sandwiches:bread_crumbs", "sandwiches:bread_crumbs", "sandwiches:bread_crumbs"},
    }
  })
  minetest.register_craft({
    type = "cooking",
    output = "sandwiches:sweet_bread_pudding",
    recipe = "sandwiches:sweet_bread_pudding_raw",
    cooktime = 15,
  })

-- JAM AND JELLY --

  minetest.register_craftitem("sandwiches:multi_jam", {
      description = "Multi jam",
      on_use = minetest.item_eat(2),
      groups = {food = 2, food_jam = 1, flammable = 1},
      inventory_image = "sandwiches_multi_jam.png"
  })
  minetest.register_craft({
  	output = "sandwiches:multi_jam 5",
  	recipe = {
  		{"group:food_berry", "group:food_sugar", "group:food_berry"},
  		{"group:food_sugar", "group:food_pot", "group:food_sugar"},
  		{"group:food_berry", "group:food_sugar", "group:food_berry"},
  	},
  	replacements = {{"group:food_pot", pot}},
  })
  minetest.register_craft({
  	output = "sandwiches:multi_jam 3",
  	type = "shapeless";
  	recipe = { "group:food_jam", "group:food_jam", "group:food_jam", },
})

  local jj = {
    ["blue"] =  { {food_jam = 1, food_blueberry_jam = 1, flammable = 1},},
    ["rasp"] =  { {food_jam = 1, food_raspberry_jam = 1, flammable = 1},},
    ["straw"] = { {food_jam = 1, food_strawberry_jam = 1, flammable = 1},},
    ["black"] = { {food_jam = 1, food_blackberry_jam = 1, flammable = 1},},
  }
  for k, v in pairs(jj) do
    minetest.register_craftitem("sandwiches:".. k .."berry_jam", {
        description = k:gsub("(%a)(%a+)", function(a, b) return string.upper(a) .. string.lower(b) end).."berry jam",
        on_use = minetest.item_eat(2),
        groups = v[1],
        inventory_image = "sandwiches_".. k .."berry_jam.png"
    })

    minetest.register_craft({
    	output = "sandwiches:".. k .."berry_jam 5",
    	recipe = {
    		{"group:food_".. k .."berry", "group:food_sugar", "group:food_".. k .."berry"},
    		{"group:food_sugar", "group:food_pot", "group:food_sugar"},
    		{"group:food_".. k .."berry", "group:food_sugar", "group:food_".. k .."berry"},
    	},
    	replacements = {{"group:food_pot", pot }},
    })
  end

  minetest.register_craftitem("sandwiches:grape_jelly", {
      description = "Grape jelly",
      on_use = minetest.item_eat(2),
      groups = {food = 2, food_jam = 1, flammable = 1 },
      inventory_image = "sandwiches_grape_jelly.png"
  })
  minetest.register_craft({
  	output = "sandwiches:grape_jelly 5",
  	recipe = {
  		{"group:food_grapes", "group:food_sugar", "group:food_grapes"},
  		{"group:food_sugar", "group:food_pot", "group:food_sugar"},
  		{"group:food_grapes", "group:food_sugar", "group:food_grapes"},
  	},
  	replacements = {{"group:food_pot", pot }},
  })


end -- if merries are registered

-- MEAT -- moved

-- PEANUTS -- moved

-- SAUCE --

minetest.register_node("sandwiches:tabasco", {
	description = "Tabasco bottle",
	inventory_image = "tabasco.png",
	wield_image = "tabasco.png",
	drawtype = "plantlike",
	paramtype = "light",
	is_ground_content = false,
	tiles = {"tabasco.png"},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1, food_hot = 1, food_spicy = 1, food_sauce = 1},
	sounds = default.node_sound_glass_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
})
minetest.register_craft({
	output = "sandwiches:tabasco 3",
	type = "shapeless";
	recipe = {"group:food_chili_pepper", "group:food_chili_pepper", "group:food_chili_pepper",
			  "group:food_chili_pepper", "group:food_chili_pepper", "group:food_chili_pepper",
			  "group:food_mortar_pestle", "vessels:glass_bottle",
	},
	replacements = {{"group:food_mortar_pestle", mope }}
})

-- TASTY VEGGIES --
local herb = "group:food_parsley"
local rosm = "group:food_pepper_ground"
if sandwiches.ingredient_support.herbs then
  herb = "potted_farming:sage"
  rosm = "group:food_rosemary"
end

  minetest.register_craftitem("sandwiches:butter_carrots", {
  	description = "Butter carrots",
  	on_use = minetest.item_eat(3),
    groups = {food = 3, food_tasty_veggie = 1, flammable = 1},
  	inventory_image = "butter_carrots.png"
  })
  minetest.register_craft({
    output = "sandwiches:butter_carrots 5",
    type = "shapeless",
    recipe = {
      "group:food_carrot", "group:food_carrot",
      "group:food_skillet", "group:food_butter", herb,
    },
    replacements = {{"group:food_skillet", skillet }}
  })

  minetest.register_craftitem("sandwiches:roasted_potatoes", {
  	description = "Roasted potatoes",
  	on_use = minetest.item_eat(4),
    groups = {food = 4, food_tasty_veggie = 1, flammable = 1},
    inventory_image = "roasted_potatoes.png"
  })
  minetest.register_craft({
  	output = "sandwiches:roasted_potatoes 5",
  	type = "shapeless",
  	recipe = {
  		"group:food_potato", "group:food_potato",
  		"group:food_skillet", "group:food_oil", rosm,
  	},
  	replacements = {
      {"group:food_skillet", skillet },
      {"group:food_pepper_ground", "vessels:glass_bottle"},
      {"group:food_oil", "vessels:glass_bottle"}, }
  })

  minetest.register_craftitem("sandwiches:caramelized_onion", {
  	description = "Caramelized onion",
  	on_use = minetest.item_eat(3),
    groups = {food = 3, food_tasty_veggie = 1, flammable = 1},
  	inventory_image = "caramelized_onion.png"
  })
  minetest.register_craft({
    output = "sandwiches:caramelized_onion 4",
    type = "shapeless";
    recipe = {"group:food_onion", "group:food_onion", "group:food_sugar", "group:food_skillet"},
    replacements = {{"group:food_skillet", skillet }}
  })

if sandwiches.ingredient_support.mushroom then
  minetest.register_craftitem("sandwiches:trifolat_mushrooms", {
  	description = "Trifolat Mushrooms",
  	on_use = minetest.item_eat(3),
    groups = {food = 3, food_tasty_veggie = 1, flammable = 1},
  	inventory_image = "trifolat_mushrooms.png"
  })
  minetest.register_craft({
    output = "sandwiches:trifolat_mushrooms 4",
    type = "shapeless",
    recipe = {
      "group:food_mushroom", "group:food_mushroom", "group:food_garlic_clove",
      "group:food_skillet", "group:food_oil", "group:food_parsley",
    },
    replacements = {{"group:food_skillet", skillet },
                    {"group:food_oil", "vessels:glass_bottle" },}
  })
end

-- --

dofile(sandwiches.path .. "/crops/peanuts.lua")


local sandwiches_recipes = {
--[[	 name,                  is definable,	fancy name, hunger,
                              recipe,
                              alternative recipe (optional),
                              replacements (optional),
]]--
  ["american"] =             {{"veggie", "meat", "dairy"}, "American", 8,
                              {"group:food_cucumber", "group:food_ham", "group:food_cheese"},
                              {"group:food_cucumber", "group:food_bacon", "group:food_cheese"},
                             },
  ["veggie"] =               {{"veggie", "veggie", "veggie"}, "Veggie", 8,
                              {"group:food_cucumber", "group:food_tomato", "group:food_potato"},
                              {"group:food_carrot", "group:food_onion", "group:food_beetroot"},
                             },
  ["classic"] =              {{"veggie", "meat", "veggie"}, "Classic", 8,
                              {"group:food_lettuce", "group:food_ham", "group:food_tomato"},
                              {"group:food_lettuce", "farming:tofu_cooked", "group:food_tomato" }
                             },
  ["blt"] =                  {{"veggie", "meat", "veggie"}, "BLT", 8,
                              {"group:food_lettuce", "group:food_bacon" ,"group:food_tomato"},
                             },
  ["ham"] =                  {{"meat", "meat", "meat"}, "Ham", 8,
                              {"group:food_ham", "group:food_ham", "group:food_ham"},
                             },
  ["bacon"] =                {{"meat", "meat", "meat"}, "Bacon", 8,
                              {"group:food_bacon", "group:food_bacon", "group:food_bacon"},
                             },
  ["egg_and_bacon"] =        {{"meat", "meat", "meat"}, "Egg&Bacon", 10,
                              {"group:food_bacon", "group:food_egg_fried", "group:food_bacon"},
                             },
  ["tasty_meat"] =           {{"veggie", "meat", "veggie"}, "Tasty veggie with meat", 10,
                              {"group:food_tasty_veggie", "group:food_ham", "group:food_tasty_veggie"},
                              {"group:food_tasty_veggie", "sandwiches:chicken_strips", "group:food_tasty_veggie"}
                             },
  ["enhanced_bacon"] =       {{"meat", "mushroom", "meat"}, "Enhanced bacon", 10,
                              {"group:food_bacon", "sandwiches:trifolat_mushrooms", "group:food_bacon"},
                             },
  ["tasty_veggie"] =         {{"veggie", "veggie", "veggie"}, "Tasty veggie", 10,
                              {"sandwiches:caramelized_onion", "sandwiches:butter_carrots" ,"sandwiches:roasted_potatoes" },
                              {"group:food_tasty_veggie", "group:food_tasty_veggie" ,"group:food_tasty_veggie" },
                             },
  ["hot_ham"] =              {{"meat", "veggie", "meat"}, "Hot ham", 9,
                              {"group:food_ham", "sandwiches:tabasco", "group:food_ham"},
                              nil,
                              {{"sandwiches:tabasco", "vessels:glass_bottle"},},
                             },
  ["hot_veggie"] =           {{"veggie", "veggie", "veggie"}, "Hot veggie", 9,
                              {"group:food_tomato", "sandwiches:tabasco", "group:food_potato"},
                              {"group:food_carrot", "sandwiches:tabasco", "group:food_onion"},
                              {{"sandwiches:tabasco", "vessels:glass_bottle"},}
                             },
  ["italian"] =              {{"mushroom", "veggie", "dairy"}, "Italian", 7,
                              {"flowers:mushroom_brown", "group:food_tomato", "group:food_cheese"},
                             },
  ["cheesy"] =               {{"dairy", "dairy", "dairy"}, "Cheesy", 8,
                              {"group:food_cheese","group:food_cheese", "group:food_cheese"},
                             },
  ["sweet"] =                {{"true", "honey", "true"}, "Sweet", 8, -- apples are from default, a dependant mod
                              {"default:apple", "group:food_honey", "default:apple"},
                              nil,
                              {{"cucina_vegana:dandelion_honey", "vessels:glass_bottle"},
                               {"petz:honey_bottle", "vessels:glass_bottle"}},
                             },
  ["blueberry_jam"] =        {{"veggie", "veggie", "veggie"}, "Blueberry jam", 7,
                              {"sandwiches:blueberry_jam", "sandwiches:blueberry_jam", "sandwiches:blueberry_jam"},
                             },
  ["raspberry_jam"] =        {{"veggie", "veggie", "veggie"}, "Raspberry jam", 7,
                              {"sandwiches:raspberry_jam", "sandwiches:raspberry_jam", "sandwiches:raspberry_jam"},
                             },
  ["strawberry_jam"] =       {{"veggie", "veggie", "veggie"}, "Strawberry jam", 7,
                              {"sandwiches:strawberry_jam", "sandwiches:strawberry_jam", "sandwiches:strawberry_jam"},
                             },
  ["blackberry_jam"] =       {{"veggie", "veggie", "veggie"}, "Blackberry jam", 7,
                              {"sandwiches:blackberry_jam", "sandwiches:blackberry_jam", "sandwiches:blackberry_jam"},
                             },
  ["grape_jelly"] =          {{"veggie", "veggie", "veggie"}, "Grape jelly", 7,
                              {"sandwiches:grape_jelly", "sandwiches:grape_jelly", "sandwiches:grape_jelly"},
                             },
  ["pb_and_j"] =             {{"true", "veggie", "true"}, "PeanutButter & Jelly", 10, -- peanut_butter is provided
                              {"sandwiches:peanut_butter", "sandwiches:grape_jelly", "sandwiches:peanut_butter"},
                             },
  ["jam"] =                  {{"veggie", "veggie", "veggie"}, "Jam", 7,
                              {"group:food_jam","group:food_jam", "group:food_jam"},
                             },
  ["banana_and_chocolate"] = {{"banana", "choco", "banana"}, "Banana&Chocolate", 8,
                              {"group:food_banana", "farming:chocolate_dark", "group:food_banana"},
                              {"group:food_banana", "cacaotree:milk_chocolate", "group:food_banana"},
                             },
  ["elvis"] =                {{"banana", "true", "meat"}, "Elvis", 9,
                              {"group:food_banana", "sandwiches:peanut_butter", "group:food_bacon"},
                             },
  ["marinated_chicken"] =    {{"veggie", "meat", "honey"}, "Marinated chicken", 10,
                              {"group:food_soy_sauce", "group:food_chicken_strips", "group:food_honey"},
                              nil,
                              {{"cucina_vegana:dandelion_honey", "vessels:glass_bottle"},
                               {"petz:honey_bottle", "vessels:glass_bottle"},
                               {"farming:soy_sauce", "vessels:glass_bottle"}},
                             },
}

local function ingredients_registered (ingredient_types)
  local s = sandwiches.ingredient_support
  local can_register = false
  if s[ingredient_types[1]] and s[ingredient_types[2]] and s[ingredient_types[3]] then
    can_register = true
  end

  return can_register
end

for k, v in pairs(sandwiches_recipes) do

  if ingredients_registered(v[1]) then
    local replace
    if v[6] ~= nil then
      replace = v[6]
    end
  	minetest.register_craftitem("sandwiches:".. k .."_sandwich", {
  		description = v[2].." sandwich",
  		on_use = minetest.item_eat(v[3], "sandwiches:bread_crumbs"),
  		groups = {food = v[3] ,food_sandwich = 1, flammable = 1},
  		inventory_image = k .."_sandwich.png",
  	})

  	minetest.register_craft({
  		output = "sandwiches:".. k .."_sandwich",
  		recipe = {
  			{"", "sandwiches:bread_slice", ""},
  			v[4],
  			{"", "sandwiches:bread_slice", ""},
  		},
      replacements = replace
  	})

  	if v[5] ~= nil then
  		minetest.register_craft({
  			output = "sandwiches:".. k .."_sandwich",
  			recipe = {
  				{"", "sandwiches:bread_slice", ""},
  				v[5],
  				{"", "sandwiches:bread_slice", ""},
  			},
        replacements = replace
  		})
  	end

  end -- registerable

end

-- ALIASES for compatibility, no unknown nodes or items must exist ---

--minetest.register_alias("name", "convert_to")
minetest.register_alias("sandwiches:rasperry_jam_sandwich", "sandwiches:raspberry_jam_sandwich")
minetest.register_alias("sandwiches:tasty_bacon_sandwich", "sandwiches:tasty_meat_sandwich")
minetest.register_alias("sandwiches:tasty_chicken_sandwich", "sandwiches:tasty_meat_sandwich")
minetest.register_alias("sandwiches:tasty_ham_sandwich", "sandwiches:tasty_meat_sandwich")
minetest.register_alias("sandwiches:classic_vegan_sandwich", "sandwiches:classic_sandwich")

-- SPECIAL SANDWICHES --

minetest.register_craftitem("sandwiches:triple_mega_sandwich", {
	description = "Triple Mega sandwich",
	on_use = minetest.item_eat(20, "sandwiches:bread_crumbs"),
	groups = {food = 20, food_big_sandwich = 1, flammable = 1},
	inventory_image = "triple_mega_sandwich.png"
})
minetest.register_craft({
	output = "sandwiches:triple_mega_sandwich",
	recipe = {
		{"", "sandwiches:bread_slice", ""},
		{"group:food_sandwich", "group:food_sandwich","group:food_sandwich"},
		{"", "sandwiches:bread_slice", ""},
	}
})

minetest.register_craftitem("sandwiches:sand_sandwich", {
  description = "Sand-sandwich",
  inventory_image = "sand_sandwich.png",
  groups = {food = 5, food_sandwich = 1, flammable = 1},
  on_use = function(itemstack, player, pointed_thing)
		if player:get_hp() > 2 then
			player:set_hp(player:get_hp() - 2)
			minetest.chat_send_player(player:get_player_name(), "Ouch!" )
	  end
    return minetest.do_item_eat(5, nil, itemstack, player, pointed_thing)
	end,
})
minetest.register_craft({
	output = "sandwiches:sand_sandwich",
	recipe = {
		{"default:sand", "default:sand", "default:sand"},
		{"default:cactus", "default:cactus", "default:cactus"},
		{"default:sand", "default:sand", "default:sand"},
	}
})
if sandwiches.ingredient_support.dairy then

--fairy bread, (butter and sprinkles)
minetest.register_craftitem("sandwiches:sprinkles", {
		description = "Sprinkles",
		on_use = minetest.item_eat(1),
		groups = {food = 1, food_sprinkles = 1, flammable = 1},
		inventory_image = "sugar_sprinkles.png"
})
minetest.register_craft({
	output = "sandwiches:sprinkles 5",
	recipe = {
		{"dye:red", "group:food_sugar", "dye:yellow"},
		{"group:food_sugar", "group:food_sugar", "group:food_sugar"},
		{"dye:blue", "group:food_mixing_bowl", "dye:green"},
	},
	replacements = {{"group:food_mixing_bowl", mix }}
})

minetest.register_craftitem("sandwiches:fairy_bread", {
		description = "Fairy bread",
		on_use = minetest.item_eat(6, "sandwiches:bread_crumbs"),
		groups = {food = 6, food_fairy_bread = 1, flammable = 1},
		inventory_image = "fairy_bread.png"
})
minetest.register_craft({
		output = "sandwiches:fairy_bread 2",
		recipe = {
			{"sandwiches:sprinkles", "sandwiches:sprinkles", "sandwiches:sprinkles"},
			{"sandwiches:sprinkles", "sandwiches:sprinkles", "sandwiches:sprinkles"},
			{"sandwiches:bread_slice", "group:food_butter", "sandwiches:bread_slice"},
		},
})

end -- if dairy is present ( need butter )
