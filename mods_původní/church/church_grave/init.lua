
screwdriver = screwdriver or {}

grave = {}

display_lib.register_display_entity("church_grave:text")

local stone_sounds = nil
if minetest.get_modpath("sounds") then
	stone_sounds = sounds.node_stone()
elseif minetest.get_modpath("default") then
	stone_sounds = default.node_sound_stone_defaults()
elseif minetest.get_modpath("hades_sounds") then
	stone_sounds = hades_sounds.node_sound_stone_defaults()
end

--Grave Markers
minetest.register_node('church_grave:grave', {
	description = 'Grave Stone',
	tiles = {'grave_stone_mossy.png', 'grave_stone.png',
	'grave_stone.png', 'grave_stone_mossy.png',
	'grave_stone_mossy.png', 'grave_stone.png'},
	groups = {cracky = 3, oddly_breakable_by_hand = 2, choppy =1 },
	drawtype = 'nodebox',
	paramtype = 'light',
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	is_ground_content = false,
	buildable_to = false,
	--light_source = 1,
	sounds = stone_sounds,
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.3125, -0.3125, -0.125, 0.3125, 0.3125, 0.125},
			{-0.375, -0.4375, -0.1875, 0.375, -0.3125, 0.1875},
			{-0.4375, -0.5, -0.25, 0.4375, -0.4375, 0.25},
			{-0.25, 0.3125, -0.125, 0.25, 0.375, 0.125},
			{-0.125, 0.375, -0.125, 0.125, 0.4375, 0.125},
		}
	},
	--[[
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},--]]
	display_entities = {
		["church_grave:text"] = {
			on_display_update = font_lib.on_display_update,
			depth = -2/16-0.001, height = 2/16,
			size = { x = 14/16, y = 12/16 },
			resolution = { x = 144, y = 64 },
			maxlines = 3,
			},
		},
	on_place = display_lib.on_place,
	on_construct = 	function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[6,4]"..
		"textarea[0.5,0.7;5.5,2;display_text;Displayed text (3 lines max);${display_text}]"..
									"button_exit[2,3;2,1;ok;Write]")
		display_lib.on_construct(pos)
	end,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
	on_receive_fields = function(pos, formname, fields, player)
		if not minetest.is_protected(pos, player:get_player_name()) then
			local meta = minetest.get_meta(pos)
			if fields and fields.ok then
				meta:set_string("display_text", fields.display_text)
				meta:set_string("infotext", "\""..fields.display_text.."\"")
				display_lib.update_entities(pos)
			end
		end
	end,
})

minetest.register_node('church_grave:grave_fancy', {
	description = 'Cemetary Cross',
	tiles = {'grave_stone_mossy.png', 'grave_stone.png',
	'grave_stone_mossy.png', 'grave_stone.png',
	'grave_stone_mossy.png', 'grave_stone.png'},
	groups = {cracky = 3, oddly_breakable_by_hand = 2, choppy =1 },
	drawtype = 'nodebox',
	paramtype = 'light',
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	is_ground_content = false,
	buildable_to = false,
	--light_source = 1,
	sounds = stone_sounds,
	on_rotate = screwdriver.rotate_simple,
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.125, -0.25, -0.125, 0.125, 0.5, 0.125},
			{-0.3125, 0.0625, -0.125, 0.3125, 0.3125, 0.125},
			{-0.1875, -0.375, -0.1875, 0.1875, -0.25, 0.1875},
			{-0.3125, -0.5, -0.3125, 0.3125, -0.375, 0.3125},
		}
	},
	--[[
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	}--]]
})

minetest.register_node('church_grave:grave_simple', {
	description = 'Simple Cemetary Cross',
	tiles = {'grave_stone_mossy.png', 'grave_stone.png',
	'grave_stone.png', 'grave_stone.png',
	'grave_stone_mossy.png', 'grave_stone.png'},
	groups = {cracky = 3, oddly_breakable_by_hand = 2, choppy =1 },
	drawtype = 'nodebox',
	paramtype = 'light',
	paramtype2 = 'facedir',
	sunlight_propagates = true,
	is_ground_content = false,
	buildable_to = false,
	--light_source = 1,
	sounds = stone_sounds,
	on_rotate = screwdriver.rotate_simple,
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.0625, -0.375, -0.0625, 0.0625, 0.5, 0.0625},
			{-0.25, 0.125, -0.0625, 0.25, 0.25, 0.0625},
			{-0.125, -0.4375, -0.125, 0.125, -0.375, 0.125},
			{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
		}
	},
	--[[
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	}--]]
})

-----------
--Crafting
-----------
local items = {
		stone = "default:stone",
		stone_slab = "stairs:slab_stone",
		stone_wall = "walls:stone",
	}

if minetest.get_modpath("hades_core") then
	items.stone = "hades_core:stone"
	items.stone_slab = "hades_stairs:slab_stone"
	items.stone_wall = "hades_walls:stone"
end

minetest.register_craft({
	output = 'church_grave:grave',
	recipe = {
		{ items.stone},
		{ items.stone_slab},
	}
})

minetest.register_craft({
	output = 'church_grave:grave_fancy',
	recipe = {
		{ 'church_cross:stone'},
		{ items.stone_slab},
	}
})

minetest.register_craft({
	output = 'church_grave:grave_simple',
	recipe = {
		{ 'church_cross:stone'},
		{ items.stone_wall},
	}
})

