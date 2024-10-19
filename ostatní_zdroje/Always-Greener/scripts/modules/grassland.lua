
awg: register_node('sage', {
	displayname = 'Sage',
	tiles = {'awg_sage.png'},
	inventory_image = 'awg_sage_inv.png',
	drawtype = 'plantlike',
	paramtype2 = 'meshoptions',
	place_param2 = 42,
	visual_scale = 1.5,
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, flower = 1, snappy = 3, flammable = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_decoration({
	deco_type = 'simple',
	decoration = 'always_greener:sage',
	place_on = {'default:dirt_with_grass'},
	biomes = {'grassland'},
	sidelen = 4,
	noise_params = {
		offset = -0.9,
		scale = 0.9,
		spread = {x = 110, y = 110, z = 110},
		seed = 241,
		octaves = 3,
		persist = 1.0
	},
	y_max = 31000,
	y_min = 1,
	param2 = 42
})

local function plant_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

awg: register_node('clover', {
	displayname = 'Clover',
	tiles = {'awg_clover.png'},
	inventory_image = 'awg_clover_inv.png',
	drawtype = 'mesh',
	mesh = 'awg_clover.obj',
	use_texture_alpha = 'clip',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.4, -0.5, -0.4, 0.4, -0.4, 0.4}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = plant_after_place
})

awg: register_node('clover_flower', {
	displayname = 'Flowering Clover',
	tiles = {'awg_clover_flower.png'},
	inventory_image = 'awg_clover_flower_inv.png',
	drawtype = 'mesh',
	mesh = 'awg_clover.obj',
	use_texture_alpha = 'clip',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.4, -0.5, -0.4, 0.4, -0.4, 0.4}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = plant_after_place
})

minetest.register_decoration({
	deco_type = 'simple',
	decoration = 'always_greener:clover',
	place_on = {'default:dirt_with_grass'},
	biomes = {'grassland'},
	sidelen = 8,
	noise_params = {
		offset = 0.02,
		scale = 0.15,
		spread = {x = 140, y = 140, z = 140},
		seed = 604,
		octaves = 3,
		persist = 0.6
	},
	y_max = 31000,
	y_min = 1,
	param2 = 0,
	param2_max = 239
})

minetest.register_decoration({
	deco_type = 'simple',
	decoration = 'always_greener:clover_flower',
	place_on = {'default:dirt_with_grass'},
	biomes = {'grassland'},
	sidelen = 8,
	noise_params = {
		offset = -0.02,
		scale = 0.15,
		spread = {x = 140, y = 140, z = 140},
		seed = 604,
		octaves = 3,
		persist = 0.6
	},
	y_max = 31000,
	y_min = 1,
	param2 = 0,
	param2_max = 239
})

awg: register_node('field_mushroom_1', {
	displayname = 'Field Mushroom',
	tiles = {'awg_field_mushroom_top.png', 'awg_field_mushroom_top.png', 'awg_field_mushroom_side.png'},
	inventory_image = 'awg_field_mushroom_inv.png',
	drawtype = 'nodebox',
	use_texture_alpha = 'clip',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0463855, -0.5, -0.0463855, 0.0463855, -0.364458, 0.0463855},
			{-0.106024, -0.404217, -0.112651, 0.106024, -0.230422, 0.112651}
		}
	},
	groups = {mushroom = 1, snappy = 3, flammable = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		node.name = 'always_greener:field_mushroom_' .. math.random(1, 3)
		minetest.swap_node(pos, node)
	end,
	on_use = minetest.item_eat(1)
})

awg: inherit_item('always_greener:field_mushroom_1', 'field_mushroom_2', {
	description = '',
	node_box = {
		type = "fixed",
		fixed = {
			{-0.13253, -0.516867, 0.205422, -0.039759, -0.357831, 0.311446},
			{-0.178916, -0.443976, 0.165663, 0.0066265, -0.28494, 0.351205},
			{0.271687, -0.516867, -0.39759, 0.404217, -0.357831, -0.26506},
			{-0.145783, -0.523494, -0.245181, -0.026506, -0.404217, -0.125904}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.13253, -0.516867, 0.205422, -0.039759, -0.357831, 0.311446},
			{-0.178916, -0.443976, 0.165663, 0.0066265, -0.28494, 0.351205},
			{0.271687, -0.516867, -0.39759, 0.404217, -0.357831, -0.26506},
			{-0.145783, -0.523494, -0.245181, -0.026506, -0.404217, -0.125904}
		}
	},
	drop = 'always_greener:field_mushroom_1',
	groups = {not_in_creative_inventory = 1}
})

awg: inherit_item('always_greener:field_mushroom_1', 'field_mushroom_3', {
	description = '',
	node_box = {
		type = "fixed",
		fixed = {
			{-0.291566, -0.5, -0.357831, -0.185542, -0.377711, -0.238554},
			{-0.351205, -0.385843, -0.41747, -0.125904, -0.212048, -0.178916},
			{0.0861446, -0.5, 0.26506, 0.192169, -0.377711, 0.384337},
			{0.0596386, -0.41747, 0.245181, 0.218675, -0.278313, 0.404217}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.291566, -0.5, -0.357831, -0.185542, -0.377711, -0.238554},
			{-0.351205, -0.385843, -0.41747, -0.125904, -0.212048, -0.178916},
			{0.0861446, -0.5, 0.26506, 0.192169, -0.377711, 0.384337},
			{0.0596386, -0.41747, 0.245181, 0.218675, -0.278313, 0.404217}
		}
	},
	drop = 'always_greener:field_mushroom_1',
	groups = {not_in_creative_inventory = 1}
})

minetest.register_decoration({
	name = 'always_greener:field_mushroom_1',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 9,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'grassland'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:field_mushroom_1',
})

minetest.register_decoration({
	name = 'always_greener:field_mushroom_2',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 3,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'grassland'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:field_mushroom_2',
})

minetest.register_decoration({
	name = 'always_greener:field_mushroom_3',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 14,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'grassland'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:field_mushroom_3',
})

local function rush_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.name = 'awg:bulrush_' .. math.random(1, 2)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

awg: register_node('bulrush_1', {
	displayname = 'Bulrushes',
	tiles = {'awg_bulrush_1.png'},
	use_texture_alpha = 'clip',
	inventory_image = 'awg_bulrush_inv.png',
	drawtype = 'mesh',
	mesh = 'awg_bulrush.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = rush_after_place
})

awg: register_node('bulrush_2', {
	tiles = {'awg_bulrush_2.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_bulrush.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = 'awg:bulrush_1'
})

awg: register_node('bulrush_rooted_1', {
	tiles = {'awg_bulrush_1.png', 'awg_mud.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_bulrush_rooted.obj',
	paramtype = 'light',
	sunlight_propagates = true,
	buildable_to = true,
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.35, 0.5, -0.35, 0.35, 1.5, 0.35},
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = 'awg:bulrush_1',
	node_dig_prediction = 'always_greener:mud',
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.set_node(pos, {name = 'always_greener:mud'})
	end
})

awg: register_node('bulrush_rooted_2', {
	tiles = {'awg_bulrush_2.png', 'awg_mud.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_bulrush_rooted.obj',
	paramtype = 'light',
	sunlight_propagates = true,
	buildable_to = true,
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.35, 0.5, -0.35, 0.35, 1.5, 0.35},
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = 'awg:bulrush_1',
	node_dig_prediction = 'always_greener:mud',
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.set_node(pos, {name = 'always_greener:mud'})
	end
})

minetest.register_decoration({
	name = 'always_greener:bulrushes',
	deco_type = 'simple',
	place_on = {
		'default:dirt', 'default:dirt_with_grass',
		'default:dry_dirt', 'default:dry_dirt_with_grass',
		'always_greener:mud', 'always_greener:mud_with_grass'
	},
	sidelen = 8,
	fill_ratio = 0.5,
	biomes = {
		'taiga_ocean',
		'taiga',
		'grassland_ocean',
		'grassland',
		'snowy_grassland_ocean',
		'snowy_grassland',
		'coniferous_forest_ocean',
		'coniferous_forest',
		'deciduous_forest_ocean',
		'deciduous_forest',
		'savanna_ocean',
		'savanna'
	},
	y_max = 1,
	y_min = 1,
	decoration = {
		'always_greener:bulrush_1', 'always_greener:bulrush_2'
	},
	param2 = 0,
	param2_max = 239,
	spawn_by = 'default:water_source',
	num_spawn_by = 1,
})

minetest.register_decoration({
	name = 'always_greener:bulrushes_rooted',
	deco_type = 'simple',
	place_on = {'default:sand'},
	place_offset_y = -1,
	sidelen = 8,
	fill_ratio = 1.5,
	biomes = {
		'taiga_ocean',
		'taiga',
		'grassland_ocean',
		'grassland',
		'snowy_grassland_ocean',
		'snowy_grassland',
		'coniferous_forest_ocean',
		'coniferous_forest',
		'deciduous_forest_ocean',
		'deciduous_forest',
		'savanna_ocean',
		'savanna'
	},
	y_max = 0,
	y_min = 0,
	flags = 'force_placement',
	decoration = {
		'always_greener:bulrush_rooted_1', 'always_greener:bulrush_rooted_2'
	},
	spawn_by = {
		'default:dirt', 'default:dirt_with_grass',
		'default:dry_dirt', 'default:dry_dirt_with_grass',
		'always_greener:mud', 'always_greener:mud_with_grass'
	},
	num_spawn_by = 1,
	check_offset = 0
})

local cane_nodes = {
	['always_greener:cane_bottom'] = true,
	['always_greener:cane_middle'] = true,
	['always_greener:cane_top'] = true
}

local function cane_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local node_below = minetest.get_node(pos - vector.new(0, 1, 0))
	
	if cane_nodes[node_below.name] then
		node.param2 = node_below.param2
	else
		node.param2 = math.random(0, 239)
	end
	
	minetest.swap_node(pos, node)
end

local function cane_after_dig (pos, _, _, digger)
	if not digger then return end
	
	for i = 1, 32 do
		local above = pos + vector.new(0, i, 0)
		local node_above = minetest.get_node(above)
		
		if not cane_nodes[node_above.name] then
			break
		end
		
		if not minetest.node_dig(above, node_above, digger) then
			break
		end
	end
end

awg: register_node('cane_bottom', {
	tiles = {'awg_cane_bottom.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_cane_bottom.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = 'awg:cane_middle',
	after_dig_node = cane_after_dig
})

awg: register_node('cane_middle', {
	displayname = 'Giant Cane',
	tiles = {'awg_cane_middle.png'},
	use_texture_alpha = 'clip',
	inventory_image = 'awg_cane_inv.png',
	drawtype = 'mesh',
	mesh = 'awg_cane_middle.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, snappy = 3, flammable = 1, stick = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = cane_after_place,
	after_dig_node = cane_after_dig
})

awg: register_node('cane_top', {
	displayname = 'Giant Cane Flower',
	tiles = {'awg_cane_top.png'},
	use_texture_alpha = 'clip',
	inventory_image = 'awg_cane_flower_inv.png',
	drawtype = 'mesh',
	mesh = 'awg_cane_middle.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, snappy = 3, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = cane_after_place
})

local function grass_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.name = 'awg:marshgrass_' .. math.random(1, 3)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

awg: register_node('marshgrass_1', {
	displayname = 'Marsh Grass',
	tiles = {'awg_marshgrass_1.png'},
	use_texture_alpha = 'clip',
	waving = 1,
	inventory_image = 'awg_marshgrass_inv.png',
	drawtype = 'mesh',
	mesh = 'awg_jungle_grass.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, grass = 1, snappy = 3, flammable = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	after_place_node = grass_after_place
})

awg: register_node('marshgrass_2', {
	tiles = {'awg_marshgrass_2.png'},
	use_texture_alpha = 'clip',
	waving = 1,
	drawtype = 'mesh',
	mesh = 'awg_jungle_grass.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, grass = 1, snappy = 3, flammable = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = 'awg:marshgrass_1'
})

awg: register_node('marshgrass_3', {
	tiles = {'awg_marshgrass_3.png'},
	use_texture_alpha = 'clip',
	waving = 1,
	drawtype = 'mesh',
	mesh = 'awg_jungle_grass.obj',
	paramtype2 = 'degrotate',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	groups = {plant = 1, grass = 1, snappy = 3, flammable = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_leaves_defaults(),
	drop = 'awg:marshgrass_1'
})

awg: register_item('pollen', {
	inventory_image = 'awg_pollen.png',
	displayname = 'Bulrush Pollen',
	groups = {flour = 1, food = 1},
	on_use = function(itemstack, user, pointed_thing)
		if math.random(1, 3) == 1 then
			itemstack: take_item(1)
		else
			minetest.do_item_eat(1, nil, itemstack, user, pointed_thing)
		end
		
		return itemstack
	end
})

awg: register_item('pollen_cake', {
	inventory_image = 'awg_pollen_cake.png',
	displayname = 'Pollen Cake',
	groups = {food = 1},
	on_use = minetest.item_eat(6)
})

minetest.register_craft {
	type = 'shapeless',
	output = 'pollen_cake',
	recipe = {
		'always_greener:pollen', 'always_greener:pollen', 'always_greener:pollen',
		'always_greener:pollen', 'always_greener:pollen', 'always_greener:pollen'
	}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'dye:violet 4',
	recipe = {'always_greener:sage'}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'dye:brown 4',
	recipe = {'always_greener:cane_top'}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'dye:dark_green 4',
	recipe = {'always_greener:clover'}
}

minetest.register_craft {
	type = 'shapeless',
	output = 'dye:white 4',
	recipe = {'always_greener:clover_flower'}
}

if etc.modules.mortar_and_pestle then
	etc.register_mortar_recipe('always_greener:sage', 'dye:violet 8', 2, true)
	etc.register_mortar_recipe('always_greener:cane_top', 'dye:brown 8', 3, true)
	etc.register_mortar_recipe('always_greener:clover', 'dye:dark_green 8', 3, true)
	etc.register_mortar_recipe('always_greener:clover_flower', 'dye:white 8', 3, true)
	
	etc.register_mortar_recipe('always_greener:bulrush_1', 'always_greener:pollen 3', 2, true)
else
	minetest.register_craft {
		type = 'shapeless',
		output = 'always_greener:pollen 2',
		recipe = {'always_greener:bulrush_1'}
	}
end

