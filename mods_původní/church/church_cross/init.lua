screwdriver = screwdriver or {}

cross = {}

--------------------
-- Node Registration
--------------------
--Cross Standards
cross.register_cross = function( basename, texture, description, craft_from, mat_sounds, wallcross )
	local group_def = {cracky = 3, oddly_breakable_by_hand = 2};

	minetest.register_node('church_cross:cross_'..basename, {
		description = description.. ' Cross',
		tiles = {texture },
		drawtype = 'nodebox',
		paramtype = 'light',
		paramtype2 = 'facedir',
		light_source = 7,
		sunlight_propagates = true,
		is_ground_content = false,
		buildable_to = false,
		on_rotate = screwdriver.rotate_simple,
		groups = group_def,
		sounds = mat_sounds,
		node_box = {
			type = 'fixed',
			fixed = {
				{-0.0625, -0.5, -0.0625, 0.0625, 0.4375, 0.0625},
				{-0.25, 0.0625, -0.0625, 0.25, 0.1875, 0.0625},
			}
		},
		selection_box = {
			type = 'fixed',
			fixed = {
				{-0.375, -0.5, -0.0625, 0.375, 0.5, 0.0625},
			},
		},
	})

  if wallcross then
		minetest.register_node('church_cross:wallcross_'..basename, {
			description = description.. ' Wall Cross',
			tiles = {texture },
			groups = {oddly_breakable_by_hand = 3},
			drawtype = 'nodebox',
			paramtype = 'light',
			paramtype2 = 'facedir',
			sunlight_propagates = true,
			is_ground_content = false,
			buildable_to = false,
			light_source = 7,
			sounds = mat_sounds,
			on_rotate = screwdriver.rotate_simple, --no upside down crosses :)
			node_box = {
				type = 'fixed',
				fixed = {
					{-0.0625, -0.3125, 0.4375, 0.0625, 0.3125, 0.5},
					{-0.1875, 0, 0.4375, 0.1875, 0.125, 0.5},
				}
			},
			selection_box = {
				type = 'fixed',
				fixed = {
					{-0.25, -0.5, 0.375, 0.25, 0.375, 0.5},
				}
			}
		})
	end

	-----------
	-- Crafting
	-----------
	minetest.register_craft({
		output = 'church_cross:cross_'..basename,
		recipe = {
			{'', craft_from, ''},
			{'default:stick', 'default:stick', 'default:stick'},
			{'', 'default:stick', ''}
		}
	})
	
	if wallcross then
		minetest.register_craft({
			output = 'church_cross:wallcross_'..basename,
			recipe = {
				{'church_cross:cross_'..basename},
			}
		})
	end
end

----------
-- Cooking
----------
minetest.register_craft({
	type = 'cooking',
	output = 'default:gold_ingot',
	recipe = 'church_cross:wallcross_gold',
	cooktime = 5,
})

minetest.register_craft({
	type = 'cooking',
	output = 'default:steel_ingot',
	recipe = 'church_cross:wallcross_steel',
	cooktime = 5,
})

--------------------------
-- Register Node Materials
--------------------------

local metal_sounds = nil
local stone_sounds = nil
local wood_sounds = nil
if minetest.get_modpath("sounds") then
	metal_sounds = sounds.node_metal()
	stone_sounds = sounds.node_stone()
	wood_sounds = sounds.node_wood()
elseif minetest.get_modpath("default") then
	metal_sounds = default.node_sound_metal_defaults()
	stone_sounds = default.node_sound_stone_defaults()
	wood_sounds = default.node_sound_wood_defaults()
elseif minetest.get_modpath("hades_sounds") then
	metal_sounds = hades_sounds.node_sound_metal_defaults()
	stone_sounds = hades_sounds.node_sound_stone_defaults()
	wood_sounds = hades_sounds.node_sound_wood_defaults()
end

local items = {
		gold_ingot = "default:gold_ingot",
		steel_ingot = "default:steel_ingot",
		stone = "default:stone",
		wood = "default:stick",
	}

if minetest.get_modpath("hades_core") then
	items.gold_ingot = "hades_core:gold_ingot"
	items.steel_ingot = "hades_core:steel_ingot"
	items.stone = "hades_core:stone"
	items.wood = "hades_core:stick"
end

cross.register_cross( 'gold', 'default_gold_block.png', 'Gold', items.gold_ingot, metal_sounds, true)
cross.register_cross( 'steel', 'default_steel_block.png', 'Steel', items.steel_ingot, metal_sounds, true)
cross.register_cross( 'stone', 'default_stone.png', 'Stone', items.stone, stone_sounds)
cross.register_cross( 'wood', 'default_pine_wood.png^[transformR90', 'Wood', items.wood, wood_sounds)

