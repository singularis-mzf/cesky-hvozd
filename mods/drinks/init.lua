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

drinks = {
	drink_table = {},
	juiceable = {},
	item_aliases = {}, -- mod:itemname -> drinks:...
	shortname = {
		jcu = {size = 2, name = 'vessels:drinking_glass'},
		jbo = {size = 4, name = 'vessels:glass_bottle'},
		jsb = {size = 4, name = 'vessels:steel_bottle'},
		jbu = {size = 16, name = 'bucket:bucket_empty'},
	},
	longname = {
		['vessels:drinking_glass'] = {size = 2, name = 'jcu'},
		['vessels:glass_bottle'] = {size = 4, name = 'jbo'},
		['vessels:steel_bottle'] = {size = 4, name = 'jsb'},
		['bucket:bucket_empty'] = {size = 16, name = 'jbu'},
		--[[ ['thirsty:steel_canteen'] = {size = 20, name = 'thirsty:steel_canteen'},
		['thirsty:bronze_canteen'] = {size = 30, name = 'thirsty:bronze_canteen'}, ]]
	},
}

local drink_defs = {
	apple = {
		fruitname = "default:apple",
		drink_desc1 = "jablečná šťáva",
		drink_desc2 = "jablečné šťávy",
		drink_desc4 = "jablečnou šťávu",
		color = "#ecff56",
	},
	cactus = {
		fruitname = "default:cactus",
		drink_desc1 = "kaktusová šťáva",
        drink_desc2 = "kaktusové šťávy",
		drink_desc4 = "kaktusovou šťávu",
        color = "#96F97B",
		glass_item = "farming:cactus_juice",
	},
	blueberries = {
        fruitname = "default:blueberries",
		fruitname2 = "farming:blueberries",
        drink_desc1 = "borůvková šťáva",
        drink_desc2 = "borůvkové šťávy",
		drink_desc4 = "borůvkovou šťávu",
        color = "#521dcb",
	},
	banana = {
        fruitname = "ethereal:banana",
        drink_desc1 = "banánová šťáva",
        drink_desc2 = "banánové šťávy",
		drink_desc4 = "banánovou šťávu",
        color = "#eced9f",
	},
	melon = {
        fruitname = "farming:melon_slice",
        drink_desc1 = "melounová šťáva",
        drink_desc2 = "melounové šťávy",
		drink_desc4 = "melounovou šťávu",
        color = "#ef4646",
	},
	orange = {
        fruitname = "ethereal:orange",
        drink_desc1 = "pomerančová šťáva",
        drink_desc2 = "pomerančové šťávy",
		drink_desc4 = "pomerančovou šťávu",
        color = "#ffc417",
	},
	rhubarb = {
        fruitname = "farming:rhubarb",
        drink_desc1 = "rebarborová šťáva",
        drink_desc2 = "rebarborové šťávy",
		drink_desc4 = "rebarborovou šťávu",
        color = "#fb8461",
	},
	tomato = {
        fruitname = "farming:tomato",
        drink_desc1 = "rajčatová šťáva",
        drink_desc2 = "rajčatové šťávy",
		drink_desc4 = "rajčatovou šťávu",
        color = "#d03a0e",
	},
	strawberry = {
        fruitname = "farming:strawberry",
        drink_desc1 = "jahodová šťáva",
        drink_desc2 = "jahodové šťávy",
		drink_desc4 = "jahodovou šťávu",
        color = "#ff3636",
	},
	raspberries = {
        fruitname = "farming:raspberries",
        drink_desc1 = "malinová šťáva",
        drink_desc2 = "malinové šťávy",
		drink_desc4 = "malinovou šťávu",
        color = "#C70039",
	},
	pumpkin = {
        fruitname = "farming:pumpkin_slice",
        drink_desc1 = "dýňová šťáva",
        drink_desc2 = "dýňové šťávy",
		drink_desc4 = "dýňovou šťávu",
        color = "#ffc04c",
	},
	carrot = {
        fruitname = "farming:carrot",
        drink_desc1 = "mrkvový džus",
        drink_desc2 = "mrkvového džusu",
		drink_desc4 = "mrkvový džus",
        color = "#ed9121",
		glass_item = "farming:carrot_juice",
	},
	cucumber = {
        fruitname = "farming:cucumber",
        drink_desc1 = "okurková šťáva",
        drink_desc2 = "okurkové šťávy",
		drink_desc4 = "okurkovou šťávu",
        color = "#73af59",
	},
	grapes = {
        fruitname = "farming:grapes",
        drink_desc1 = "hroznová šťáva",
        drink_desc2 = "hroznové šťávy",
		drink_desc4 = "hroznovou šťávu",
        color = "#b20056",
	},
	pineapple = {
        fruitname = "farming:pineapple_ring",
        drink_desc1 = "ananasová šťáva",
        drink_desc2 = "ananasové šťávy",
		drink_desc4 = "ananasovou šťávu",
        color = "#dcd611",
		glass_item = "farming:pineapple_juice",
	},
	plum = {
        fruitname = "plumtree:plum",
        drink_desc1 = "švestková šťáva",
        drink_desc2 = "švestkové šťávy",
		drink_desc4 = "švestkovou šťávu",
        color = "#8e4585",
	},
	coconut = {
        fruitname = "moretrees:coconut",
        drink_desc1 = "kokosové mléko",
        drink_desc2 = "kokosového mléka",
		drink_desc4 = "kokosové mléko",
        color = "#ffffff",
		glass_item = "moretrees:coconut_milk",
	},
}

-- Honestly not needed for default, but used as an example to add support to other mods.
-- Basically to use this all you need to do is add the name of the fruit to make juiceable (see line 14 for example)
-- Add the new fruit to a table like I've done in line 16.
-- The table should follow this scheme: internal name, Displayed name, colorize code.
-- Check out the drinks.lua file for more info how how the colorize code is used.
   --[[
   table.insert(drinks.drink_table, {'blackberry', 'Blackberry', '#581845'})
   table.insert(drinks.drink_table, {'blueberry', 'Blueberry', '#521dcb'})
   table.insert(drinks.drink_table, {'gooseberry', 'Gooseberry', '#9cf57c'})
   table.insert(drinks.drink_table, {'raspberry', 'Raspberry', '#C70039'})
   table.insert(drinks.drink_table, {'strawberry', 'Strawberry', '#ff3636'})
   ]]
   -- table.insert(drinks.drink_table, {'lemon', 'Lemon', '#feffaa'})
   -- table.insert(drinks.drink_table, {'peach', 'Peach', '#f2bc1e'})
   -- table.insert(drinks.drink_table, {'pear', 'Pear', '#ecff56'})
   -- table.insert(drinks.drink_table, {'peach', 'Peach', '#f2bc1e'})
   -- table.insert(drinks.drink_table, {'orange', 'Orange', '#ffc417'})

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

local glass = "vessels:drinking_glass"
local glass_bottle = "vessels:glass_bottle"
local steel_bottle = "vessels:steel_bottle"

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

for drink_id, drink_def in pairs(drink_defs) do
	if drink_def.fruitname and minetest.registered_items[drink_def.fruitname] then
		local health = drink_def.health or 1
		local def, eat_func, image

		drinks.juiceable[drink_def.fruitname] = drink_id
		if drink_def.fruitname2 then
			drinks.juiceable[drink_def.fruitname2] = drink_id
		end
		drinks.drink_table[drink_id] = {
			[1] = drink_def.drink_desc1,
			[2] = drink_def.drink_desc2,
			[3] = drink_def.drink_desc2, -- not used?
			[4] = drink_def.drink_desc4,
		}

		-- Bucket (always defined)
		image = "bucket.png^(drinks_bucket_contents.png^[colorize:"..drink_def.color..":200)"
		def = {
			description = "kbelík "..drink_def.drink_desc2,
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
		minetest.register_node("drinks:jbu_"..drink_id, def)

		if drink_def.glass_item and minetest.registered_items[drink_def.glass_item] then
			minetest.register_alias("drinks:jcu_"..drink_id, drink_def.glass_item)
			minetest.override_item(drink_def.glass_item, {juice_type = drink_id})
			drinks.item_aliases[drink_def.glass_item] = "drinks:jcu_"..drink_id
		else
			eat_func = eat_func_cache[glass][health]
			if not eat_func then
				eat_func = minetest.item_eat(health, glass)
				eat_func_cache[glass][health] = eat_func
			end
			def = {
				description = "sklenice "..drink_def.drink_desc2,
				juice_type = drink_id,
				inventory_image = "drinks_glass_contents.png^[colorize:"..drink_def.color..":200^drinks_drinking_glass.png",
				on_use = eat_func,
			}
			drinks.register_item("drinks:jcu_"..drink_id, glass, def)
		end

		if drink_def.bottle_item and minetest.registered_items[drink_def.bottle_item] then
			minetest.register_alias("drinks:jbo_"..drink_id, drink_def.bottle_item)
			minetest.override_item(drink_def.bottle_item, {juice_type = drink_id})
			drinks.item_aliases[drink_def.bottle_item] = "drinks:jbo_"..drink_id
		else
			eat_func = eat_func_cache[glass_bottle][2 * health]
			if not eat_func then
				eat_func = minetest.item_eat(2 * health, glass_bottle)
				eat_func_cache[glass_bottle][2 * health] = eat_func
			end
			def = {
				description = "láhev "..drink_def.drink_desc2,
				juice_type = drink_id, -- [ ] ?? !!!
				inventory_image = "drinks_bottle_contents.png^[colorize:"..drink_def.color..":200^drinks_glass_bottle.png",
				on_use = eat_func,
			}
			drinks.register_item("drinks:jbo_"..drink_id, glass_bottle, def)
		end

		if drink_def.steel_bottle_item and minetest.registered_items[drink_def.steel_bottle_item] then
			minetest.register_alias("drinks:jsb_"..drink_id, drink_def.steel_bottle_item)
			minetest.override_item(drink_def.steel_bottle_item, {juice_type = drink_id})
			drinks.item_aliases[drink_def.steel_bottle_item] = "drinks:jsb_"..drink_id
		else
			eat_func = eat_func_cache[steel_bottle][2 * health]
			if not eat_func then
				eat_func = minetest.item_eat(2 * health, steel_bottle)
				eat_func_cache[steel_bottle][2 * health] = eat_func
			end
			def = {
				description = "kovová láhev "..drink_def.drink_desc2,
				juice_type = drink_id, -- [ ] ?? !!!
				groups = {drink = 1},
				inventory_image = "vessels_steel_bottle.png",
				on_use = eat_func,
			}
			drinks.register_item("drinks:jsb_"..drink_id, steel_bottle, def)
		end
	end
end
--[[
for i in ipairs (drinks.drink_table) do
   local desc = drinks.drink_table[i][1]
   local craft = drinks.drink_table[i][2]
   local color = drinks.drink_table[i][3]
   local health = drinks.drink_table[i][4]
   ]]

function drinks.translate_alias(name)
	return name and (drinks.item_aliases[name] or name)
end

if minetest.get_modpath('thirsty') then
   error("Not implemented with thristy mod!")
   -- dofile(minetest.get_modpath('drinks')..'/drinks.lua')
-- else
   -- dofile(minetest.get_modpath('drinks')..'/drinks2.lua')
end
dofile(minetest.get_modpath('drinks')..'/drink_machines.lua')
dofile(minetest.get_modpath('drinks')..'/formspecs.lua')
