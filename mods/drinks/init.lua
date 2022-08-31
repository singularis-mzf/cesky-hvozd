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

local glass = "vessels:drinking_glass"
local glass_bottle = "vessels:glass_bottle"
local steel_bottle = "vessels:steel_bottle"
local bucket = "bucket:bucket_empty"

local bucket_selection_box = {
	type = "fixed",
	fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
}
local bucket_groups = {
	vessel = 1, dig_immediate = 3, attached_node = 1, drink = 1
}
local eat_func_cache = {
	[glass] = {},
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

	if not minetest.registered_items[empty_vessel_item] then
		error("Vessel item "..empty_vessel_item.." not registered by Minetest!")
	end
	if registered_vessels[empty_vessel_item] then
		error("Vessel item "..empty_vessel_item.." already registered as a bottle!")
	end
	registered_vessels[empty_vessel_item] = def

	-- TODO: Update full vessels definitions to allow drinks to be registered before vessels.

	return true
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
				local template = vessel_def.get_template(drink_id, def.drink_desc2 or def.drink_desc, color, math.ceil((def.health_per_unit or 0.5) * vessel_def.capacity))
				if template then
					full_vessel_item = "drinks:"..vessel_def.abbr3.."_"..drink_id
					if template.drawtype then
						-- node definition (like a bucket)
						minetest.register_node(full_vessel_item, template)
					else
						-- plantlike node definition
						drinks.register_item(full_vessel_item, empty_vessel_item, template)
					end
					def[empty_vessel_item] = full_vessel_item
					spill_from_results[full_vessel_item] = { drink_id = drink_id, units_produced = vessel_def.capacity, empty_vessel_item = empty_vessel_item }
				end
			end
		elseif full_vessel_item ~= false then
			if minetest.registered_items[full_vessel_item] then
				-- pre-existing item
				minetest.override_item(full_vessel_item, {juice_type = drink_id})
				spill_from_results[full_vessel_item] = { drink_id = drink_id, units_produced = vessel_def.capacity, empty_vessel_item = empty_vessel_item }
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
	}
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
	}
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
	}
end

drinks.add_vessel(glass, {
	capacity = 2,
	abbr3 = "jcu",
	get_template = get_glass_template,
})

drinks.add_vessel(glass_bottle, {
	capacity = 4,
	abbr3 = "jbo",
	get_template = get_glass_bottle_template,
})

drinks.add_vessel(steel_bottle, {
	capacity = 4,
	abbr3 = "jsb",
	get_template = get_steel_bottle_template,
	default_only_for_true = true,
})

drinks.add_vessel(bucket, {
	capacity = 16,
	abbr3 = "jbu",
	get_template = function(drink_id, drink_desc2, color, health)
		local image = "bucket.png^(drinks_bucket_contents.png^[colorize:"..color..":200)"
		return {
			description = "kbelík "..drink_desc2,
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
})

-- Drinks
drinks.add_drink("apple", "jablečná šťáva", "#ecff56", {
	drink_desc2 = "jablečné šťávy",
	drink_desc4 = "jablečnou šťávu",
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
	[glass_bottle] = "farming:cactus_juice",
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
})

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
