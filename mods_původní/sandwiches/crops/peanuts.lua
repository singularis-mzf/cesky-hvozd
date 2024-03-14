local crop_def = {}
local mope = "sandwiches:mortar_pestle"

if minetest.global_exists("farming") and  farming.mod == "redo" then
	mope = "farming:mortar_pestle"

	-- peanut seeds
	minetest.register_node("sandwiches:seed_peanut", {
		description = "Peanuts Seed",
		tiles = {"seed_peanut.png"},
		inventory_image = "sandwiches_seed_peanut.png",
		wield_image = "sandwiches_seed_peanut.png",
		drawtype = "signlike",
		groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 4},
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = false,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			return farming.place_seed(itemstack, placer, pointed_thing, "sandwiches:peanut_1")
		end,
	})
	minetest.register_craftitem("sandwiches:peanuts", {
		description = "Peanuts",
		on_use = minetest.item_eat(1),
		inventory_image = "sandwiches_peanut.png", -- not peanutS due to compatibility with the default farming mod
		groups = {food = 1, food_peanut = 1, food_peanuts = 1, flammable = 1},
	})

	minetest.register_alias("sandwiches:seed_peanuts", "sandwiches:seed_peanut")
	--minetest.register_alias("sandwiches:peanuts", "sandwiches:peanut")

	-- peanut plant definition
	crop_def = {
		drawtype = "plantlike",
		tiles = {"sandwiches_peanut_1.png"},
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		drop = "",
		selection_box = {
			type = "fixed",
			fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5},
			},
		},
		groups = { snappy = 3, flammable = 4, plant = 1, flora = 1, attached_node = 1,
			not_in_creative_inventory = 1, growing = 1 },
		sounds = default.node_sound_leaves_defaults()
	}

	-- stage 1
	minetest.register_node("sandwiches:peanut_1", table.copy(crop_def))

	-- stage 2
	crop_def.tiles = {"sandwiches_peanut_2.png"}
	minetest.register_node("sandwiches:peanut_2", table.copy(crop_def))

	-- stage 3
	crop_def.tiles = {"sandwiches_peanut_3.png"}
	crop_def.drop = {
		items = {
			{items = {'sandwiches:peanuts 2'}, rarity = 1},
			{items = {'sandwiches:peanuts'}, rarity = 2},
		}
	}
	minetest.register_node("sandwiches:peanut_3", table.copy(crop_def))


	-- stage 4
	crop_def.tiles = {"sandwiches_peanut_4.png"}
	crop_def.drop = {
		items = {
			{items = {'sandwiches:peanuts 4'}, rarity = 1},
			{items = {'sandwiches:peanuts 2'}, rarity = 2},
			{items = {'sandwiches:peanuts'}, rarity = 4},
			{items = {'sandwiches:seed_peanut 2'}, rarity = 1},
			{items = {'sandwiches:seed_peanut 2'}, rarity = 3},
		}
	}
	minetest.register_node("sandwiches:peanut_4", table.copy(crop_def))

	-- stage 5 (spreading stage)
	-- as the crop grows to the 5th stage, it has less seeds
	-- because they are "used" when spreading
	crop_def.tiles = {"sandwiches_peanut_5.png"}
	crop_def.drop = {
		items = {
			{items = {'sandwiches:peanuts 3'}, rarity = 1},
			{items = {'sandwiches:peanuts 2'}, rarity = 2},
			{items = {'sandwiches:peanuts'}, rarity = 4},
			{items = {'sandwiches:seed_peanut'}, rarity = 1},
			{items = {'sandwiches:seed_peanut'}, rarity = 2},
		}
	}
	minetest.register_node("sandwiches:peanut_5", table.copy(crop_def))

	-- stage 6 (final)
	-- the plant is "exhausted" from the spreading
	crop_def.tiles = {"sandwiches_peanut_6.png"}
	crop_def.groups.growing = 0
	crop_def.drop = {
		items = {
			{items = {'sandwiches:peanuts 3'}, rarity = 1},
			{items = {'sandwiches:peanuts 2'}, rarity = 2},
			{items = {'sandwiches:peanuts'}, rarity = 4},
			{items = {'sandwiches:seed_peanut'}, rarity = 1},
			{items = {'sandwiches:seed_peanut'}, rarity = 4},
		}
	}
	minetest.register_node("sandwiches:peanut_6", table.copy(crop_def))

	if minetest.get_modpath("bonemeal") then
		bonemeal:add_crop({ {"sandwiches:peanut_", 6, "sandwiches:seed_peanut"}, })
	end

else -- farming-redo not present -----------------------------------------------

	farming.register_plant("sandwiches:peanut", {
		description = "Peanut Seed",
	  harvest_description = "Peanuts",
		inventory_image = "sandwiches_seed_peanut.png",
		steps = 6,
		minlight = 12,
		maxlight = default.LIGHT_MAX,
		fertility = {"grassland"},
		groups = {flammable = 4, attached_node = 1, snappy = 3, plant = 1, flora = 1,},
	})
	if minetest.registered_items["sandwiches:peanuts"] then
		minetest.override_item("sandwiches:peanuts", {
			--description = "Peanuts",
			on_use = minetest.item_eat(1),
			inventory_image = "sandwiches_peanut.png",
			groups = {food = 1, food_peanut = 1, food_peanuts = 1, flammable = 1},
		})
	end

	if minetest.get_modpath("bonemeal") then
		bonemeal:add_crop({ {"sandwiches:peanut_", 5, "sandwiches:seed_peanut"}, })
	end

end -- register different plant nodes

minetest.register_abm({
   name = "sandwiches:peanut_spreading_abm",
   nodenames = {"sandwiches:peanut_5"},
   interval = 5,
   chance = 5,
   action = function(pos, node)
      -- Check 3x3x3 nodes around the currently triggered node
      local soil_positions = minetest.find_nodes_in_area_under_air(
         vector.add(pos, -1), vector.add(pos, 1),
         {"farming:soil_wet", "farming:soil"}
      )
      if(next(soil_positions) ~= null) then
        local found_soil_pos = soil_positions[math.random(#soil_positions)]
				found_soil_pos.y = found_soil_pos.y +1
				minetest.set_node(found_soil_pos, {name="sandwiches:peanut_1"})
				if(math.random(10) > 5) then
					minetest.set_node(pos,{name="sandwiches:peanut_6"})
				end
	  	end
   end
})

-- WILD PEANUTS --

minetest.register_node("sandwiches:wild_peanut", {
	description = "Wild Peanuts",
	paramtype = "light",
	walkable = false,
	drop =  {
		items = {
			{items = {'sandwiches:peanuts'}, rarity = 1},
			{items = {'sandwiches:peanuts'}, rarity = 2},
			{items = {'sandwiches:seed_peanut 2'}, rarity = 1},
			{items = {'sandwiches:seed_peanut'}, rarity = 3},
		}
	},
	drawtype = "plantlike",
	paramtype2 = "facedir",
	tiles = {"sandwiches_peanut_4.png"},
	inventory_image = "sandwiches_peanut_4.png",
	wield_image = "sandwiches_peanut_4.png",
	groups = {snappy = 3, dig_immediate=1, flammable=2, plant=1, flora = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
			type = "fixed",
			fixed = {	{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5},	},
	},
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:dirt"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.0003,
		spread = {x = 70, y = 70, z = 70},
		seed = 2570,
		octaves = 3,
		persist = 0.6
	},
	y_min = 0,
	y_max = 100,
	decoration = "sandwiches:wild_peanut",
})

-- PEANUT BUTTER --

minetest.register_craftitem("sandwiches:peanut_butter", {
    description = "Peanut Butter",
    on_use = minetest.item_eat(2),
    groups = {food = 2, food_peanut_butter = 1, flammable = 1},
    inventory_image = "sandwiches_peanut_butter.png"
})

minetest.register_craft({
	output = "sandwiches:peanut_butter 5",
	type = "shapeless";
	recipe = {"sandwiches:peanuts", "sandwiches:peanuts", "sandwiches:peanuts",
		"sandwiches:peanuts", "sandwiches:peanuts", "sandwiches:peanuts",
		"group:food_mortar_pestle","sandwiches:peanuts", "sandwiches:peanuts",
	},
	replacements = {{"group:food_mortar_pestle", mope }},
})
