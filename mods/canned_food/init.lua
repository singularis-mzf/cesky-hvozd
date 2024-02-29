-- CANNED FOOD
-- Introduces new food types to add some variety. All of them rely on glass bottles
-- from the default vessels mod, which otherwise sees very little use. In vanilla game,
-- at least 4 new types will be available, two of which will also turn inedible items
-- into edible food. With farming (redo) and ethereal, pretty much anything that can
-- be harvested can also be canned.

--[[
    Definition scheme
	internal_name_of_the_product = {
		proper_name = Human-readable name,
		found_in = mod name where the source object is introduced
		obj_name = name of source object
		orig_nutritional_value = self-explanatory
		amount = how many objects are needed to fill a bottle /not implemented/
		sugar = boolean, set if needs sugar (jams) or not
		transforms = name of the product it turns into if left on a shelf
	}
	image files for items must follow the scheme "internal_name_of_the_product.png"
]]

local S = minetest.get_translator("canned_food")

if minetest.get_modpath("unified_inventory") and unified_inventory.register_craft_type then
		unified_inventory.register_craft_type(S("nakládání"), {
				description = "Temné místo, dřevěná police",
				icon = "canned_food_pickling_icon.png",
				width = 1,
				height = 1,
				uses_crafting_grid = false,
		})
end

local canned_food_definitions = {
	apple_jam = {
		proper_name = S("jablečná marmeláda"),
		found_in = "default",
		obj_name = "default:apple",
		orig_nutritional_value = 2,
		amount = 3,
		sugar = false -- must not use sugar to be available in vanilla
	},
	wild_blueberry_jam = {
		proper_name = S("marmeláda z divokých borůvek"),
		found_in = "default",
		obj_name = "default:blueberries",
		orig_nutritional_value = 2,
		amount = 6,
		sugar = false -- must not use sugar to be available in vanilla
	},
	dandelion_jam = {
		proper_name = S("pampelišková marmeláda"),
		found_in = "flowers",
		obj_name = "flowers:dandelion_yellow",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = false -- must not use sugar to be available in vanilla
	},
	rose_jam = {
		proper_name = S("růžová marmeláda"),
		found_in = "flowers",
		obj_name = "flowers:rose",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = false -- must not use sugar to be available in vanilla
	},
	canned_mushrooms = {
		proper_name = S("zavařené žampiony"),
		found_in = "flowers",
		obj_name = "flowers:mushroom_brown",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = false,
		transforms = "uleželé zavařené žampiony"
	},
	orange_jam = {
		proper_name = S("pomerančový džem"),
		found_in = "farming",
		obj_name = "ethereal:orange",
		orig_nutritional_value = 2,
		amount = 3,
		sugar = true
	},
	banana_jam = {
		proper_name = S("banánový džem"),
		found_in = "farming",
		obj_name = "ethereal:banana",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = true
	},
	strawberry_jam = {
		proper_name = S("jahodová marmeláda"),
		found_in = "ethereal",
		obj_name = "ethereal:strawberry",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = true
	},
	--[[
	canned_wild_onion = {
		proper_name = "Canned wild onions",
		found_in = "ethereal",
		obj_name = "ethereal:wild_onion_plant",
		orig_nutritional_value = 2,
		amount = 4,
		sugar = false,
		transforms = "Pickled wild onions"
	}, ]]
	blueberry_jam = {
		proper_name = S("borůvková marmeláda"),
		found_in = "farming",
		obj_name = "farming:blueberries",
		orig_nutritional_value = 1,
		amount = 6,
		sugar = true
	},
	blackberry_jam = {
		proper_name = S("ostružinová marmeláda"),
		found_in = "farming",
		obj_name = "farming:blackberry",
		orig_nutritional_value = 1,
		amount = 6,
		sugar = true
	},
	raspberry_jam = {
		proper_name = S("malinová marmeláda"),
		found_in = "farming",
		obj_name = "farming:raspberries",
		orig_nutritional_value = 1,
		amount = 6,
		sugar = true
	},
	grape_jam = {
		proper_name = S("grepová marmeláda"),
		found_in = "farming",
		obj_name = "farming:grapes",
		orig_nutritional_value = 2,
		amount = 4,
		sugar = true
	},
	rhubarb_jam = {
		proper_name = S("rebarborová marmeláda"),
		found_in = "farming",
		obj_name = "farming:rhubarb",
		orig_nutritional_value = 1,
		amount = 6,
		sugar = true
	},
	melon_jam = {
		proper_name = S("melounová marmeláda"),
		found_in = "farming",
		obj_name = "farming:melon_slice",
		orig_nutritional_value = 2,
		amount = 3,
		sugar = true
	},
	canned_carrot = {
		proper_name = S("nakládané mrkve"),
		found_in = "farming",
		obj_name = "farming:carrot",
		orig_nutritional_value = 4,
		amount = 3,
		sugar = false,
		transforms = "uleželé nakládané mrkve"
	},
	canned_potato = {
		proper_name = S("nakládané brambory"),
		found_in = "farming",
		obj_name = "farming:potato",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = false,
		-- a rare thing, apparently
		transforms = S("uleželé nakládané brambory")
	},
	canned_cucumber = {
		proper_name = S("nakládané okurky"),
		found_in = "farming",
		obj_name = "farming:cucumber",
		orig_nutritional_value = 4,
		amount = 3,
		sugar = false,
		-- one just cannot simply make the pickles
		transforms = S("uleželé nakládané okurky")
	},
	canned_tomato = {
		proper_name = S("zavařená rajčata"),
		found_in = "farming",
		obj_name = "farming:tomato",
		orig_nutritional_value = 4,
		amount = 3,
		sugar = false,
		transforms = S("uleželá zavařená rajčata")
	},
	canned_corn = {
		proper_name = S("nakládané kukuřičné klasy"),
		found_in = "farming",
		obj_name = "farming:corn",
		orig_nutritional_value = 3,
		amount = 3,
		sugar = false
	},
	canned_beans = {
		proper_name = S("nakládané fazole"),
		found_in = "farming",
		obj_name = "farming:beans",
		orig_nutritional_value = 1,
		amount = 6,
		sugar = false
	},
	canned_chili_pepper = {
		proper_name = S("nakládané čili papričky"),
		found_in = "farming",
		obj_name = "farming:chili_pepper",
		orig_nutritional_value = 1,
		amount = 6,
		sugar = false,
		transforms = S("uleželé nakládané čili papričky")
	},
	canned_coconut = {
		proper_name = S("nakládaný kokos"),
		found_in = "moretrees",
		obj_name = "moretrees:coconut",
		orig_nutritional_value = 1,
		amount = 1,
		sugar = false
	},
	--[[
	pine_nuts_jar = {
		proper_name = "A Jar of pine nuts",
		found_in = "ethereal",
		obj_name = "ethereal:pine_nuts",
		orig_nutritional_value = 1,
		amount = 8,
		sugar = false
	}, ]]
	canned_pumpkin = {
		proper_name = S("dýňová marmeláda"),
		found_in = "farming",
		obj_name = "farming:pumpkin_slice",
		orig_nutritional_value = 2,
		amount = 3,
		sugar = false
	},
	honey_jar = {
		proper_name = S("sklenice medu"),
		found_in = "mobs_animal",
		obj_name = "mobs:honey",
		orig_nutritional_value = 4,
		amount = 4,
		sugar = false
	},
	canned_pineapple = {
		proper_name = S("zavařené ananasové kroužky"),
		found_in = "farming",
		obj_name = "farming:pineapple_ring",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = false
	},
	canned_onion = {
		proper_name = S("nakládaná cibule"),
		found_in = "farming",
		obj_name = "farming:onion",
		orig_nutritional_value = 1,
		amount = 4,
		sugar = false,
		transforms = S("uleželá nakládaná cibule")
	},
	canned_garlic_cloves = {
		proper_name = S("nakládaný česnek"),
		found_in = "farming",
		obj_name = "farming:garlic_clove",
		orig_nutritional_value = 0.5,
		amount = 8,
		sugar = false,
		transforms = S("uleželý nakládaný česnek")
	},
	canned_peas = {
		proper_name = S("zavařený hrášek"),
		found_in = "farming",
		obj_name = "farming:peas",
		orig_nutritional_value = 1,
		amount = 8,
		sugar = false,
	},
	canned_beetroot = {
		proper_name = S("zavařená červená řepa"),
		found_in = "farming",
		obj_name = "farming:beetroot",
		orig_nutritional_value = 1,
		amount = 5,
		sugar = false,
		transforms = S("uleželá zavařená červená řepa")
	},
}

local lbm_list = {}

-- creating all objects with one universal scheme
for product, def in pairs(canned_food_definitions) do
	if minetest.get_modpath(def.found_in) then
	--if minetest.global_exists(def.found_in) then
		if def.sugar and minetest.get_modpath("farming") or not def.sugar then

			-- general description

			local food_value = math.max(1, math.floor (def.orig_nutritional_value * def.amount * 1.33) + (def.sugar and 1 or 0))

			local nodetable = {
				description = def.proper_name,
				drawtype = "plantlike",
				tiles = {"canned_food_" .. product .. ".png"},
				inventory_image = "canned_food_" .. product .. ".png",
				wield_image = "canned_food_" .. product .. ".png",
				paramtype = "light",
				is_ground_content = false,
				walkable = false,
				selection_box = {
					type = "fixed",
					fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
				},
				groups = { canned_food = 1,
			                 vessel = 1,
			                 dig_immediate = 3,
			                 attached_node = 1,
			                 ch_food = food_value,
					},
				-- canned food prolongs shelf life IRL, but in minetest food never
				-- goes bad. Here, we increase the nutritional value instead.
				on_use = ch_core.item_eat("vessels:glass_bottle"),
				-- the empty bottle stays, of course
				sounds = default.node_sound_glass_defaults(),
			}


			if not def.transforms then
			-- introducing a new item, a bit more nutricious than the source
			-- material when sugar is used. Always stays the same.
				minetest.register_node("canned_food:" .. product, nodetable)

			else
			-- Some products involve marinating or salting, however there is no salt
			-- or vingerar in minetest; instead we imitate this more complex process
			-- by putting the jar on a wooden shelf in a dark room for a long while.
			-- The effort is rewarded accordingly.

				-- adding transformation code
				nodetable.on_construct = function(pos)
						local t = minetest.get_node_timer(pos)
						t:start(180)
					end

				nodetable.on_timer = function(pos)
						-- if light level is 11 or less, and wood is nearby, there is 1 in 10 chance...
						if minetest.get_node_light(pos) > 11 or
						   not minetest.find_node_near(pos, 1, {"group:wood"})
						   or math.random() > 0.1 then
							return true
						else
							minetest.set_node(pos, {name = "canned_food:" .. product .."_plus"})
							return false
						end
					end

				minetest.register_node("canned_food:" .. product, nodetable)

				-- add node to the list for LBM
				table.insert(lbm_list, "canned_food:" .. product)

				local food_value = math.max(1, (math.floor (def.orig_nutritional_value * def.amount * 1.33) + (def.sugar and 1 or 0)) * 2)

				-- a better version
				minetest.register_node("canned_food:" .. product .."_plus", {
					description = def.transforms,
					drawtype = "plantlike",
					tiles = {"canned_food_" .. product .. ".png^canned_food_paper_lid_cover.png"},
					inventory_image = "canned_food_" .. product .. ".png^canned_food_paper_lid_cover.png",
					wield_image = "canned_food_" .. product .. ".png^canned_food_paper_lid_cover.png",
					paramtype = "light",
					is_ground_content = false,
					walkable = false,
					selection_box = {
						type = "fixed",
						fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
					},
					groups = { canned_food = 1,
						vessel = 1,
						dig_immediate = 3,
						attached_node = 1,
						canned_food_plus = 1,
						ch_food = food_value,
					},
					-- the reward for putting the food in a cellar is even greater
					-- than for merely canning it.
					on_use = ch_core.item_eat("vessels:glass_bottle"),
					-- the empty bottle stays, of course
					sounds = default.node_sound_glass_defaults(),
				})

				-- register the recipe with unified inventory
				if minetest.get_modpath("unified_inventory") and unified_inventory.register_craft then
					unified_inventory.register_craft({
						type = S("nakládání"),
						output = "canned_food:" .. product .."_plus",
						items = {"canned_food:" .. product},
					})
				end

			end

			-- a family of shapeless recipes, with sugar for jams
			-- except for apple: there should be at least 1 jam guaranteed
			-- to be available in vanilla game (and mushrooms are the guaranteed
			-- regular - not sweet - canned food)
			local ingredients = {"vessels:glass_bottle"}
			local max = 8
			if def.sugar then
				table.insert(ingredients, "farming:sugar")
				max = 7
			end
			-- prevent creation of a recipe with more items than there are slots
			-- left in the 9-tile craft grid
			if def.amount > max then
				def.amount = max
			end
			for i=1,def.amount do
				table.insert(ingredients, def.obj_name)
			end
			minetest.register_craft({
				type = "shapeless",
				output = "canned_food:" .. product,
				recipe = ingredients
			})
		end
	end
end


-- LBM to start timers on existing, ABM-driven nodes
minetest.register_lbm({
	name = "canned_food:timer_init",
	nodenames = lbm_list,
	run_at_every_load = false,
	action = function(pos)
		local t = minetest.get_node_timer(pos)
		t:start(180)
	end,
})

-- The Moor has done his duty, the Moor can go
canned_food_definitions = nil
