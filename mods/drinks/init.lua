drinks = {
	registered_drinks = {},
	registered_fruits = {},
	registered_vessels = {},
}

local registered_drinks = drinks.registered_drinks
local registered_fruits = drinks.registered_fruits
local registered_vessels = drinks.registered_vessels

-- full_vessel_item => { drink_id, units_produced, empty_vessel_item }
local spill_from_results = {}

local glass = "vessels:drinking_glass" -- 0,2 l
local large_glass = "vessels:large_drinking_glass" -- 0,5 l
local glass_bottle = "vessels:glass_bottle" -- 1 l
local steel_bottle = "vessels:steel_bottle" -- 1 l
local bucket = "bucket:bucket_empty" -- 8 l
local wooden_bucket = "bucket_wooden:bucket_empty" -- 8 l
local source = ":source:" -- 1 l

local bucket_selection_box = {
	type = "fixed",
	fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
}
local bucket_groups = {
	vessel = 1, dig_immediate = 3, attached_node = 1, drink = 1
}
local eat_func_cache = {
	[source] = {},
	[glass] = {},
	[large_glass] = {},
	[glass_bottle] = {},
	[steel_bottle] = {},
}

-- replace craftitem to node definition
-- use existing node as template (e.g. 'vessel:glass_bottle')
function drinks.register_item(name, template, def)
	local template_def = minetest.registered_nodes[template]
   if template_def then
   local drinks_def = table.copy(template_def)

   -- replace/add values
   for k,v in pairs(def) do
      if k == "groups" then
         -- special handling for groups: merge instead replace
         for g,n in pairs(v) do
            drinks_def[k][g] = n
         end
      else
         drinks_def[k]=v
      end
   end

   if def.inventory_image then
      drinks_def.wield_image = drinks_def.inventory_image
      drinks_def.tiles = { drinks_def.inventory_image }
   end

   minetest.register_node( name, drinks_def )
   end
end

function drinks.add_vessel(empty_vessel_item, def)
	def.empty_vessel_item = empty_vessel_item
	-- required fields:
	--		 capacity, abbr3
	-- optional fields:
	--		get_template, default_only_for_true

	if not def.capacity then
		error("Missing capacity for vessel: "..empty_vessel_item)
	end
	if not def.abbr3 then
		error("Missing abbr3 for vessel: "..empty_vessel_item)
	end

	for _, _ in pairs(registered_drinks) do
		error("All vessels must be registered before any drinks!")
	end

	if empty_vessel_item ~= source and not minetest.registered_items[empty_vessel_item] then
		error("Vessel item "..empty_vessel_item.." not registered by Minetest!")
	end
	if registered_vessels[empty_vessel_item] then
		error("Vessel item "..empty_vessel_item.." already registered as a bottle!")
	end
	registered_vessels[empty_vessel_item] = def

	-- TODO: Update full vessels definitions to allow drinks to be registered before vessels.

	return true
end

local function set_spill_from_results(full_vessel_item, drink_id, units_produced, empty_vessel_item)
	if empty_vessel_item == source then
		empty_vessel_item = ""
	end
	local result = { drink_id = drink_id, units_produced = units_produced, empty_vessel_item = empty_vessel_item }
	if spill_from_results[full_vessel_item] ~= nil then
		minetest.log("warning", "[drinks] spill_from_results["..full_vessel_item.."] is already set (old drink_id = "..spill_from_results[full_vessel_item].drink_id..", new drink_id = "..drink_id..")!")
	end
	spill_from_results[full_vessel_item] = result
	return result
end

function drinks.add_drink(drink_id, drink_desc1, color, def)
	if registered_drinks[drink_id] then
		error("Drink "..drink_id.." already registered!")
	end
	registered_drinks[drink_id] = def
	def.color = color
	def.drink_desc = drink_desc1

	-- Register vessels by templates
	for empty_vessel_item, vessel_def in pairs(registered_vessels) do
		local full_vessel_item = def[empty_vessel_item]
		if full_vessel_item == true or full_vessel_item == nil then
			if vessel_def.get_template and (full_vessel_item == true or not vessel_def.default_only_for_true) then
				local template, template_type
				if empty_vessel_item ~= source then
					template, template_type =  vessel_def.get_template(drink_id, def.drink_desc2 or def.drink_desc, color, math.ceil((def.health_per_unit or 0.5) * vessel_def.capacity))
				end
				if template then
					full_vessel_item = "drinks:"..vessel_def.abbr3.."_"..drink_id
					if template_type == "node" then
						-- node definition (like a bucket)
						minetest.register_node(full_vessel_item, template)
					elseif template_type == "plantlike" then
						-- plantlike node definition
						drinks.register_item(full_vessel_item, empty_vessel_item, template)
					elseif template_type == "craftitem" then
						minetest.register_craftitem(full_vessel_item, template)
					else
						error("Invalid template_type "..(template_type or "nil").." for empty_vessel_item "..empty_vessel_item.."!")
					end
					def[empty_vessel_item] = full_vessel_item
					set_spill_from_results(full_vessel_item, drink_id, vessel_def.capacity, empty_vessel_item)
				end
			end
		elseif full_vessel_item ~= false then
			if minetest.registered_items[full_vessel_item] then
				-- pre-existing item
				local override = {juice_type = drink_id}

				if empty_vessel_item == glass and def.override_glass_tiles and empty_vessel_item ~= source and vessel_def.get_template then
					local template, template_type = vessel_def.get_template(drink_id, def.drink_desc2 or def.drink_desc, color, math.ceil((def.health_per_unit or 0.5) * vessel_def.capacity))
					if template then
						if template_type == "node" or template_type == "plantlike" then
							local tiles = template.tiles
							if tiles == nil and template.inventory_image ~= nil then
								tiles = {template.inventory_image}
							end
							if tiles ~= nil then
								override.tiles = tiles
								override.inventory_image = tiles[1]
								override.wield_image = tiles[1]
							end
						elseif template_type == "craftitem" then
							override.inventory_image = template.inventory_image
							override.wield_image = template.wield_image or template.inventory_image
						else
							error("Invalid template_type "..(template_type or "nil").." for empty_vessel_item "..empty_vessel_item.."!")
						end
					end
				end

				minetest.override_item(full_vessel_item, override)
				set_spill_from_results(full_vessel_item, drink_id, vessel_def.capacity, empty_vessel_item)
			else
				-- non-existent item
				def[empty_vessel_item] = false
			end
		end
	end

	return true
end

function drinks.add_fruit(drink_id, fruit_item, units_produced)
	if registered_fruits[fruit_item] then
		error("Fruit item "..fruit_item.." already registered!")
	end
	if not registered_drinks[drink_id] then
		error("Drink "..drink_id.." not registered!")
	end
	registered_fruits[fruit_item] = {
		drink_id = drink_id,
		units_produced = units_produced,
	}
	return true
end

function drinks.fill_to(drink_id, empty_vessel_item)
	-- RETURNS: { full_vessel_item, units_required }
	-- or nil when not supported
	local vessel_def, drink_def, full_vessel_item, result
	vessel_def = registered_vessels[empty_vessel_item]
	if vessel_def then
		drink_def = registered_drinks[drink_id]
		if drink_def then
			full_vessel_item = drink_def[empty_vessel_item]
			if full_vessel_item then
				result = { full_vessel_item = full_vessel_item, units_required = vessel_def.capacity }
			end
		end
	end
	-- print("DEBUG: fill_to("..drink_id..", "..empty_vessel_item..") => "..dump2(result))
	return result
end

function drinks.spill_from(full_vessel_item)
	-- RETURNS: { drink_id, units_produced, empty_vessel_item } or nil when not supported
	local result = spill_from_results[full_vessel_item]
	-- print("DEBUG: spill_from("..full_vessel_item..") = "..dump2(result))
	return result
end

function drinks.get_juice(fruit_item)
	-- RETURNS: { drink_id, units_produced } or nil when not supported
	return registered_fruits[fruit_item]
end

-- Vessels
local function get_glass_template(drink_id, drink_desc2, color, health)
	local eat_func = eat_func_cache[glass][health]
	if not eat_func then
		eat_func = minetest.item_eat(health, glass)
		eat_func_cache[glass][health] = eat_func
	end
	return {
		description = "sklenice "..drink_desc2,
		juice_type = drink_id,
		inventory_image = "drinks_glass_contents.png^[colorize:"..color..":200^drinks_drinking_glass.png",
		on_use = eat_func,
	}, "plantlike"
end

local function get_large_glass_template(drink_id, drink_desc2, color, health)
	local eat_func = eat_func_cache[large_glass][health]
	if not eat_func then
		eat_func = minetest.item_eat(health, large_glass)
		eat_func_cache[large_glass][health] = eat_func
	end
	return {
		description = "půllitr "..drink_desc2,
		juice_type = drink_id,
		inventory_image = "drinks_glass_contents.png^[colorize:"..color..":200^drinks_drinking_glass.png",
		on_use = eat_func,
	}, "plantlike"
end

local function get_glass_bottle_template(drink_id, drink_desc2, color, health)
	local eat_func = eat_func_cache[glass_bottle][health]
	if not eat_func then
		eat_func = minetest.item_eat(health, glass_bottle)
		eat_func_cache[glass_bottle][health] = eat_func
	end
	return {
		description = "láhev "..drink_desc2,
		juice_type = drink_id,
		inventory_image = "drinks_bottle_contents.png^[colorize:"..color..":200^drinks_glass_bottle.png",
		on_use = eat_func,
	}, "plantlike"
end

local function get_steel_bottle_template(drink_id, drink_desc2, color, health)
	local eat_func = eat_func_cache[steel_bottle][health]
	if not eat_func then
		eat_func = minetest.item_eat(health, steel_bottle)
		eat_func_cache[steel_bottle][health] = eat_func
	end
	return {
		description = "kovová láhev "..drink_desc2,
		juice_type = drink_id,
		groups = {drink = 1},
		inventory_image = "vessels_steel_bottle.png",
		on_use = eat_func,
	}, "craftitem"
end

drinks.add_vessel(glass, {
	capacity = 2, -- 0,2 l
	abbr3 = "jcu",
	get_template = get_glass_template,
})

drinks.add_vessel(large_glass, {
	capacity = 5, -- 0,5 l
	abbr3 = "jlu",
	get_template = get_large_glass_template,
	default_only_for_true = true,
})

drinks.add_vessel(glass_bottle, {
	capacity = 10, -- 1 l
	abbr3 = "jbo",
	get_template = get_glass_bottle_template,
})

drinks.add_vessel(steel_bottle, {
	capacity = 10, -- 1 l
	abbr3 = "jsb",
	get_template = get_steel_bottle_template,
	default_only_for_true = true,
})

drinks.add_vessel(bucket, {
	capacity = 80, -- 8 l
	abbr3 = "jbu",
	get_template = function(drink_id, drink_desc2, color, health)
		local image = "bucket.png^(drinks_bucket_contents.png^[colorize:"..color..":200)"
		return {
			description = "kbelík "..drink_desc2,
			-- drawtype = "plantlike",
			-- tiles = {image},
			inventory_image = image,
			wield_image = image,
			--paramtype = "light",
			juice_type = drink_id,
			-- is_ground_content = false,
			-- walkable = false,
			-- selection_box = bucket_selection_box,
			groups = bucket_groups,
			-- sounds = default.node_sound_defaults(),
		}, "craftitem"
	end,
})

drinks.add_vessel(source, {
	capacity = 10,
	abbr3 = "src",
	-- no get_template!
})

if minetest.get_modpath("bucket_wooden") then
	drinks.add_vessel(wooden_bucket, {
		capacity = 80, -- 8 l
		abbr3 = "jwu",
		get_template = function(drink_id, drink_desc2, color, health)
			local image = "bucket_wooden.png^(drinks_bucket_contents.png^[colorize:"..color..":200)"
			return {
				description = "vědro "..drink_desc2,
				drawtype = "plantlike",
				tiles = {image},
				inventory_image = image,
				wield_image = image,
				paramtype = "light",
				juice_type = drink_id,
				is_ground_content = false,
				walkable = false,
				selection_box = bucket_selection_box,
				groups = bucket_groups,
				sounds = default.node_sound_defaults(),
			}
		end,
		default_only_for_true = true,
	})
end

-- Drinks
drinks.add_drink("apple", "jablečný mošt", "#ecff56", {
	drink_desc2 = "jablečného moštu",
	drink_desc4 = "jablečný mošt",
	[glass] = "wine:glass_apple_juice",
	[glass_bottle] = "wine:bottle_apple_juice",
})
drinks.add_fruit("apple", "default:apple", 1)

drinks.add_drink("banana", "banánová šťáva", "#eced9f", {
	drink_desc2 = "banánové šťávy",
	drink_desc4 = "banánovou šťávu",
})
drinks.add_fruit("banana", "ethereal:banana", 2)

drinks.add_drink("blueberries", "borůvková šťáva", "#521dcb", {
	drink_desc2 = "borůvkové šťávy",
	drink_desc4 = "borůvkovou šťávu",
})
drinks.add_fruit("blueberries", "default:blueberries", 1)
drinks.add_fruit("blueberries", "farming:blueberries", 1)

drinks.add_drink("cactus", "kaktusová šťáva", "#96F97B", {
	drink_desc2 = "kaktusové šťávy",
	drink_desc4 = "kaktusovou šťávu",
	[glass] = "farming:cactus_juice",
})
drinks.add_fruit("cactus", "default:cactus", 2)

drinks.add_drink("carrot", "mrkvový džus", "#ed9121", {
	drink_desc2 = "mrkvového džusu",
	drink_desc4 = "mrkvový džus",
	[glass] = "farming:carrot_juice",
})
drinks.add_fruit("carrot", "farming:carrot")

drinks.add_drink("cucumber", "okurková šťáva", "#73af59", {
	drink_desc2 = "okurkové šťávy",
	drink_desc4 = "okurkovou šťávu",
})
drinks.add_fruit("cucumber", "farming:cucumber", 2)

drinks.add_drink("melon", "melounová šťáva", "#ef4646", {
	drink_desc2 = "melounové šťávy",
	drink_desc4 = "melounovou šťávu",
})
drinks.add_fruit("melon", "farming:melon_slice", 4)

drinks.add_drink("orange", "pomerančová šťáva", "#ffc417", {
	drink_desc2 = "pomerančové šťávy",
	drink_desc4 = "pomerančovou šťávu",
})
drinks.add_fruit("orange", "ethereal:orange", 2)

drinks.add_drink("pumpkin", "dýňová šťáva", "#ffc04c", {
	drink_desc2 = "dýňové šťávy",
	drink_desc4 = "dýňovou šťávu",
})
drinks.add_fruit("pumpkin", "farming:pumpkin_slice", 2)

drinks.add_drink("raspberries", "malinová šťáva", "#C70039", {
	drink_desc2 = "malinové šťávy",
	drink_desc4 = "malinovou šťávu",
})
drinks.add_fruit("raspberries", "farming:raspberries", 1)

drinks.add_drink("strawberry", "jahodová šťáva", "#ff3636", {
	drink_desc2 = "jahodové šťávy",
	drink_desc4 = "jahodovou šťávu",
})
drinks.add_fruit("strawberry", "farming:strawberry", 1)

drinks.add_drink("tomato", "rajčatová šťáva", "#d03a0e", {
	drink_desc2 = "rajčatové šťávy",
	drink_desc4 = "rajčatovou šťávu",
})
drinks.add_fruit("tomato", "farming:tomato", 2)

drinks.add_drink("grapes", "hroznová šťáva", "#b20056", {
	drink_desc2 = "hroznové šťávy",
	drink_desc4 = "hroznovou šťávu",
})
drinks.add_fruit("grapes", "farming:grapes", 2)

drinks.add_drink("pineapple", "ananasová šťáva", "#dcd611", {
	drink_desc2 = "ananasové šťávy",
	drink_desc4 = "ananasovou šťávu",
	[glass] = "farming:pineapple_juice",
})
drinks.add_fruit("pineapple", "farming:pineapple_ring", 1)

drinks.add_drink("plum", "švestková šťáva", "#8e4585", {
	drink_desc2 = "švestkové šťávy",
	drink_desc4 = "švestkovou šťávu",
})
drinks.add_fruit("plum", "plumtree:plum", 1)

drinks.add_drink("coconut", "kokosové mléko", "#ffffff", {
	drink_desc2 = "kokosového mléka",
	drink_desc4 = "kokosové mléko",
	[glass] = "moretrees:coconut_milk",
})
drinks.add_fruit("coconut", "moretrees:coconut")

	--[[ rhubarb = {
        fruitname = "farming:rhubarb",
        drink_desc1 = "rebarborová šťáva",
        drink_desc2 = "rebarborové šťávy",
		drink_desc4 = "rebarborovou šťávu",
        color = "#fb8461",
	}, ]]

drinks.add_drink("water", "voda", "#2b639e", {
	drink_desc2 = "vody",
	drink_desc4 = "vodu",
	[glass] = "farming:glass_water",
	[bucket] = "bucket:bucket_water",
	[source] = "default:water_source",
})

drinks.add_drink("soy_milk", "sójové mléko", "#d8d0c2", {
	drink_desc2 = "sójového mléka",
	drink_desc4 = "sójové mléko",
	[glass] = "farming:soy_milk",
})

drinks.add_drink("mint_tea", "mátový čaj", "#d2df56", {
	drink_desc2 = "mátového čaje",
	drink_desc4 = "mátový čaj",
	[glass] = "farming:mint_tea",
})

-- mobs_animal
if minetest.get_modpath("mobs_animal") then
	drinks.add_drink("milk", "mléko", "#ffffff", {
		drink_desc2 = "mléka",
		drink_desc4 = "mléko",
		[glass] = "mobs:glass_milk",
		[bucket] = "mobs:bucket_milk",
		[wooden_bucket] = "mobs:bucket_wooden_milk",
	})
end

-- wine
if minetest.get_modpath("wine") then
	drinks.add_drink("wine", "víno", "#e00d7a", {
		drink_desc2 = "vína",
		drink_desc4 = "víno",
		[glass] = "wine:glass_wine",
		[glass_bottle] = "wine:bottle_wine",
		[bucket] = false,
	})

	drinks.add_drink("beer", "tmavé pivo", "#f1c200", {
		drink_desc2 = "tmavého piva",
		drink_desc4 = "tmavé pivo",
		[large_glass] = "wine:glass_beer",
		[glass_bottle] = "wine:bottle_beer",
		[bucket] = false,
	})

	drinks.add_drink("lemonade", "limonáda", "#aa6d5d", { -- ? divná barva
		drink_desc2 = "limonády",
		drink_desc4 = "limonádu",
		[glass] = "wine:glass_lemonade",
		[glass_bottle] = "wine:bottle_lemonade",
		[bucket] = false,
	})

	drinks.add_drink("tequila", "tekila", "#fdffc7", {
		drink_desc2 = "tekily",
		drink_desc4 = "tekilu",
		[glass] = "wine:glass_tequila",
		[glass_bottle] = "wine:bottle_tequila",
		[bucket] = false,
	})

	drinks.add_drink("sake", "saké", "#e9ffff", { -- barva?
		-- drink_desc2 = "saké",
		-- drink_desc4 = "",
		[glass] = false, -- má misku, ne sklenici
		[glass_bottle] = "wine:bottle_sake",
		[bucket] = false,
	})

	drinks.add_drink("bourbon", "burbon", "#e47603", {
		drink_desc2 = "burbonu",
		drink_desc4 = "burbon",
		[glass] = "wine:glass_bourbon",
		[glass_bottle] = false,
		[bucket] = false,
	})

	drinks.add_drink("vodka", "vodka", "#d9e3f1", {
		drink_desc2 = "vodky",
		drink_desc4 = "vodku",
		[glass] = "wine:glass_vodka",
		[glass_bottle] = "wine:bottle_vodka",
		[bucket] = true,
	})

	drinks.add_drink("mead", "medovina", "#eb9912", {
		drink_desc2 = "medoviny",
		drink_desc4 = "medovinu",
		[glass] = "wine:glass_mead",
		[glass_bottle] = "wine:bottle_mead",
		[bucket] = true,
	})

	drinks.add_drink("mint_julep", "mentolový likér", "#4d945d", {
		drink_desc2 = "mentolového likéru",
		drink_desc4 = "mentolový likér",
		[glass] = "wine:glass_mint",
		[glass_bottle] = "wine:bottle_mint",
		[bucket] = false,
	})

	drinks.add_drink("brandy", "brandy", "#ff6c21", {
		-- drink_desc2 = "brandy",
		-- drink_desc4 = "",
		[glass] = "wine:glass_brandy",
		[glass_bottle] = "wine:bottle_brandy",
		[bucket] = false,
	})

	drinks.add_drink("coffee_liquor", "kávový likér", "#743c10", {
		drink_desc2 = "kávového likéru",
		drink_desc4 = "kávový likér",
		[glass] = "wine:glass_coffee_liquor",
		[glass_bottle] = "wine:bottle_coffee_liquor",
		[bucket] = false,
	})

	drinks.add_drink("champagne", "šampaňské", "#ffbf00", { -- barva?
		drink_desc2 = "šampaňského",
		drink_desc4 = "šampaňské",
		[glass] = "wine:glass_champagne",
		[glass_bottle] = "wine:bottle_champagne",
		[bucket] = false,
	})

		drinks.add_drink("wheat_beer", "světlé pivo", "#f1c200", {
		drink_desc2 = "světlého piva",
		drink_desc4 = "světlé pivo",
		[large_glass] = "wine:glass_wheat_beer",
		[glass_bottle] = "wine:bottle_wheat_beer",
		[bucket] = false,
	})

	drinks.add_drink("cointreau", "cointreau", "#ff6c21", {
		[glass] = "wine:glass_cointreau",
		[glass_bottle] = "wine:bottle_cointreau",
		[bucket] = false,
	})

	drinks.add_drink("kefir", "kefír", "#f5e6c8", {
		drink_desc2 = "kefíru",
		[glass] = "wine:glass_kefir",
		[glass_bottle] = "wine:bottle_kefir",
	})

	drinks.add_drink("margarita", "margarita", "#e0d07a", {
		drink_desc2 = "margarity",
		drink_desc4 = "margaritu",
		[glass] = "wine:glass_margarita",
		[glass_bottle] = "wine:bottle_margarita",
		[bucket] = false,
	})

	drinks.add_drink("sparkling_agave_juice", "perlivá agávová šťáva", "#97c8d4", {
		drink_desc2 = "perlivé agávové šťávy",
		drink_desc4 = "perlivou agávovou šťávu",
		[glass] = "wine:glass_sparkling_agave_juice",
		[glass_bottle] = "wine:sparkling_agave_juice",
		[bucket] = false,
	})

	drinks.add_drink("sparkling_apple_juice", "perlivá jablečná šťáva", "#e1b787", {
		drink_desc2 = "perlivé jablečné šťávy",
		drink_desc4 = "perlivou jablečnou šťávu",
		[glass] = "wine:glass_sparkling_apple_juice",
		[glass_bottle] = "wine:sparkling_apple_juice",
		[bucket] = false,
	})

	drinks.add_drink("sparkling_carrot_juice", "perlivá mrkvová šťáva", "#e1b787", {
		drink_desc2 = "perlivé mrkvové šťávy",
		drink_desc4 = "perlivou mrkvovou šťávu",
		[glass] = "wine:glass_sparkling_carrot_juice",
		[glass_bottle] = "wine:sparkling_carrot_juice",
		[bucket] = false,
	})

	drinks.add_drink("sparkling_blackberry_juice", "perlivá ostružinová šťáva", "#45012b", {
		drink_desc2 = "perlivé ostružinové šťávy",
		drink_desc4 = "perlivou ostružinovou šťávu",
		[glass] = "wine:glass_sparkling_blackberry_juice",
		[glass_bottle] = "wine:sparkling_blackberry_juice",
		[bucket] = false,
	})

	drinks.add_drink("burcak", "burčák", "#9fad62", {
		drink_desc2 = "burčáku",
		drink_desc4 = "burčák",
		[glass] = "wine:glass_burcak",
		override_glass_tiles = true,
	})

	drinks.add_drink("slivovice", "slivovice", "#f9fbfe", {
		drink_desc2 = "slivovice",
		drink_desc4 = "slivovici",
		[glass] = "wine:glass_slivovice",
		[glass_bottle] = "wine:bottle_slivovice",
		override_glass_tiles = true,
	})
end

-- Generate recipes for drinks and bottles

local vessels_0_2 = {glass}
local vessels_0_5 = {large_glass}
local vessels_1_0 = {glass_bottle, steel_bottle}
local vessels_8_0 = {bucket}

if minetest.get_modpath("bucket_wooden") then
	table.insert(vessels_8_0, wooden_bucket)
end

for drink_id, drink_def in pairs(drinks.registered_drinks) do

	-- 0,2 l <=> 1 l
	for _, vessel_0_2 in ipairs(vessels_0_2) do
		for _, vessel_1_0 in ipairs(vessels_1_0) do
			local fill_to_0_2 = drinks.fill_to(drink_id, vessel_0_2)
			local fill_to_1_0 = drinks.fill_to(drink_id, vessel_1_0)
			if fill_to_0_2 and fill_to_1_0 then
				local full_vessel_0_2 = fill_to_0_2.full_vessel_item
				local full_vessel_1_0 = fill_to_1_0.full_vessel_item
				minetest.register_craft({
					output = full_vessel_1_0,
					recipe = {
						{vessel_1_0, "", ""},
						{full_vessel_0_2, full_vessel_0_2, full_vessel_0_2},
						{full_vessel_0_2, full_vessel_0_2, ""},
					},
					replacements = {
						{full_vessel_0_2, vessel_0_2.." 5"},
					}
				})
				minetest.register_craft({
					output = full_vessel_0_2.." 5",
					recipe = {
						{full_vessel_1_0, "", ""},
						{vessel_0_2, vessel_0_2, vessel_0_2},
						{vessel_0_2, vessel_0_2, ""},
					},
					replacements = {
						{full_vessel_1_0, vessel_1_0},
					}
				})
			end
		end
	end

	-- 0,5 l <=> 1 l
	for _, vessel_0_5 in ipairs(vessels_0_5) do
		for _, vessel_1_0 in ipairs(vessels_1_0) do
			local fill_to_0_5 = drinks.fill_to(drink_id, vessel_0_5)
			local fill_to_1_0 = drinks.fill_to(drink_id, vessel_1_0)
			if fill_to_0_5 and fill_to_1_0 then
				local full_vessel_0_5 = fill_to_0_5.full_vessel_item
				local full_vessel_1_0 = fill_to_1_0.full_vessel_item
				minetest.register_craft({
					output = full_vessel_1_0,
					recipe = {
						{vessel_1_0, ""},
						{full_vessel_0_5, full_vessel_0_5},
					},
					replacements = {
						{full_vessel_0_5, vessel_0_5.." 2"},
					}
				})
				minetest.register_craft({
					output = full_vessel_0_5.." 2",
					recipe = {
						{full_vessel_1_0, ""},
						{vessel_0_5, vessel_0_5},
					},
					replacements = {
						{full_vessel_1_0, vessel_1_0},
					}
				})
			end
		end
	end

	-- 1 l <=> 8 l
	for _, vessel_1_0 in ipairs(vessels_1_0) do
		for _, vessel_8_0 in ipairs(vessels_8_0) do
			local fill_to_1_0 = drinks.fill_to(drink_id, vessel_1_0)
			local fill_to_8_0 = drinks.fill_to(drink_id, vessel_8_0)
			if fill_to_1_0 and fill_to_8_0 then
				local full_vessel_1_0 = fill_to_1_0.full_vessel_item
				local full_vessel_8_0 = fill_to_8_0.full_vessel_item
				minetest.register_craft({
					output = full_vessel_8_0,
					recipe = {
						{vessel_8_0, full_vessel_1_0, full_vessel_1_0},
						{full_vessel_1_0, full_vessel_1_0, full_vessel_1_0},
						{full_vessel_1_0, full_vessel_1_0, full_vessel_1_0},
					},
					replacements = {
						{full_vessel_1_0, vessel_1_0.." 8"},
					}
				})
				minetest.register_craft({
					output = full_vessel_1_0.." 8",
					recipe = {
						{full_vessel_8_0, vessel_1_0, vessel_1_0},
						{vessel_1_0, vessel_1_0, vessel_1_0},
						{vessel_1_0, vessel_1_0, vessel_1_0},
					},
					replacements = {
						{full_vessel_8_0, vessel_8_0},
					}
				})
			end
		end
	end
end

-- mod support (moreblocks/technic_worldgen)
local slab_str = "stairs:slab_wood"

--Craft Recipes
minetest.register_craft({
      output = 'drinks:juice_press',
      recipe = {
         {'default:stick', 'default:steel_ingot', 'default:stick'},
         {'default:stick', 'bucket:bucket_empty', 'default:stick'},
         {slab_str, slab_str, 'vessels:drinking_glass'},
         }
})

minetest.register_craft({
      output = 'drinks:liquid_barrel',
      recipe = {
         {'group:wood', 'group:wood', 'group:wood'},
         {'group:wood', 'group:wood', 'group:wood'},
         {slab_str, '', slab_str},
         }
})

dofile(minetest.get_modpath('drinks')..'/drink_machines.lua')
