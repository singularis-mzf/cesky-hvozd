ch_base.open_mod(minetest.get_current_modname())
minetest.register_node('church_bell:iron', {
	description = 'železný kostelní zvon',
	node_placement_prediction = '',
	drawtype = 'mesh',
	mesh = "church_bell.obj",
	tiles = {'church_bell_iron.png'},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.38, -0.31, -0.38, 0.38, 0.5, 0.38},
		}
	},
	paramtype = 'light',
	is_ground_content = true,
	inventory_image = 'church_bell_iron_inv.png',
	wield_image = 'church_bell_iron_inv.png',
	stack_max = 1,
	on_punch = function (pos,node,puncher)
		minetest.sound_play( 'church_bell_punch', { pos = pos, gain = 1.5, max_hear_distance = 300,});
		-- minetest.chat_send_all(puncher:get_player_name()..' has rung the bell!')
	end,
	groups = {cracky=2},
})

minetest.register_node('church_bell:gold', {
	description = 'zlatý kostelní zvon',
	node_placement_prediction = '',
	drawtype = 'mesh',
	mesh = "church_bell.obj",
	tiles = {'church_bell_gold.png'},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.38, -0.31, -0.38, 0.38, 0.5, 0.38},
		}
	},
	paramtype = 'light',
	is_ground_content = true,
	inventory_image = 'church_bell_gold_inv.png',
	wield_image = 'church_bell_gold_inv.png',
	stack_max = 1,
	on_punch = function (pos,node,puncher)
		minetest.sound_play( 'church_bell_punch', { pos = pos, gain = 1.5, max_hear_distance = 300,});
		-- minetest.chat_send_all(puncher:get_player_name()..' has rung the bell!')
	end,

	groups = {cracky=2},
})

-----------------------------
-- Register Craft Recipes
-----------------------------
local items = {
		gold_ingot = "default:gold_ingot",
		iron_ingot = "default:steel_ingot",
	}

if minetest.get_modpath("hades_core") then
	items.gold_ingot = "hades_core:gold_ingot"
	items.iron_ingot = "hades_core:steel_ingot"
end

minetest.register_craft({
	output = 'church_bell:gold',
	recipe = {
		{'', items.gold_ingot, ''},
		{items.gold_ingot, '', items.gold_ingot},
		{items.gold_ingot, '', items.gold_ingot},
	},
})
minetest.register_craft({
	output = 'church_bell:iron',
	recipe = {
		{'', items.iron_ingot, ''},
		{items.iron_ingot, '', items.iron_ingot},
		{items.iron_ingot, '', items.iron_ingot},
	},
})
ch_base.close_mod(minetest.get_current_modname())
