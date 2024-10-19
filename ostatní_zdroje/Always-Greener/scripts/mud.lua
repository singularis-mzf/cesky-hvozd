
awg: register_node('mud', {
	displayname = 'Mud',
	tiles = {'awg_mud.png'},
	sounds = etc.get_sound_group 'mud',
	groups = {crumbly = 1, oddly_breakable_by_hand = 1, fall_damage_add_percent = -25, soil = 1},
	drop = 'awg:mud_lump 4'
})

awg: register_item('mud_lump', {
	displayname = 'Mud Clump',
	inventory_image = 'awg_mud_lump.png'
})

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:mud',
	recipe = {
		'awg:mud_lump', 'awg:mud_lump',
		'awg:mud_lump', 'awg:mud_lump'
	}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:mud_lump 4',
	recipe = {'awg:mud'}
}

awg: inherit_item('always_greener:mud', 'mud_with_grass', {
	displayname = 'Mud With Grass',
	description = '',
	tiles = {'awg_grass.png^[multiply:#2d591d', 'awg_mud.png', 'awg_mud.png^(awg_dead_grass_side.png^[multiply:#2d591d)'}
})

if minetest.settings: get_bool('awg.craft_grass_blocks', true) then
	minetest.register_craft {
		type = 'shapeless',
		output = 'awg:mud_with_grass',
		recipe = {
			'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1',
			'always_greener:cutting_grass_1', 'awg:mud', 'always_greener:cutting_grass_1',
			'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1'
		}
	}
end

minetest.register_abm {
	label = 'Dirt to Mud',
	nodenames = {
		'default:dirt',
		'default:dirt_with_grass',
		'default:dry_dirt',
		'always_greener:dry_dirt_with_grass',
		'always_greener:dirt_with_dead_grass',
		'always_greener:dry_dirt_with_dead_grass',
		'default:dirt_with_coniferous_litter',
		'default:dirt_with_rainforest_litter',
		'default:dirt_with_snow'
	},
	neighbors = {
		'default:water_source',
		'default:water_flowing',
		'default:river_water_source',
		'default:river_water_flowing'
	},
	interval = 10,
	chance = 10,
	catch_up = true,
	action = function(pos, node)
		local nodename = node.name
		node.name = 'always_greener:mud'
		
		if nodename: find '_with_grass' then
			node.name = node.name .. '_with_grass'
		end
		
		minetest.swap_node(pos, node)
	end
}

awg: register_node('dried_mud', {
	displayname = 'Dried Mud',
	tiles = {'awg_dried_mud.png'},
	groups = {crumbly = 2, soil = 1},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft {
	type = 'cooking',
	output = 'awg:dried_mud',
	recipe = 'awg:mud',
	cooktime = 1
}

minetest.register_abm {
	label = 'Mud Drying',
	nodenames = {
		'always_greener:mud',
		'always_greener:mud_with_grass'
	},
	interval = 10,
	chance = 10,
	catch_up = true,
	action = function(pos, node)
		local water = minetest.find_node_near(pos, 2.5, {
			'default:water_source', 'default:river_water_source',
			'default:water_flowing', 'default:river_water_flowing'
		})
		
		if water then return end
		
		if node.name == 'always_greener:mud_with_grass' then
			node.param2 = awg.get_biome_color(pos)
			node.name = 'default:dirt_with_grass'
		else
			node.name = 'always_greener:dried_mud'
		end
		
		minetest.swap_node(pos, node)
	end
}
