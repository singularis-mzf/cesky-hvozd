
minetest.unregister_item 'default:dirt_with_dry_grass'
minetest.unregister_item 'default:dry_dirt_with_dry_grass'

minetest.register_alias('default:dirt_with_dry_grass', '')
minetest.register_alias('default:dry_dirt_with_dry_grass', 'always_greener:dry_dirt_with_grass')

local alt_chill = minetest.settings: get_bool('awg.grass_alt_chill', true)
local alt_dry = minetest.settings: get_bool('awg.grass_alt_dry', true)
local grass_water_prox = minetest.settings: get_bool('awg.grass_water_prox', true)

function awg.get_biome_color (pos)
	local biomedat = minetest.get_biome_data(pos)
	
	local heat = biomedat.heat
	local humidity = biomedat.humidity
	
	if pos.y > 80 then
		heat = heat - (alt_chill and ((pos.y - 80) * 0.5) or 0)
		humidity = humidity - (alt_dry and ((pos.y - 80) * 0.75) or 0)
	end
	
	if grass_water_prox then
		local water = minetest.find_node_near(pos, 8, {
			'default:water_source', 'default:river_water_source',
			'default:water_flowing', 'default:river_water_flowing'
		})
		
		if water then
			local dist = pos: distance(water)
			humidity = humidity + (math.max(0, 8 - dist - math.random(0, 1)) * 8)
		end
	end
	
	local heat_scaled = math.floor((math.max(0, math.min(heat, 100)) / 100) * 16)
	local humidity_scaled = math.floor((math.max(0, math.min(humidity, 100)) / 100) * 16)
	
	return math.max(0, math.min(255, (16 * math.min(15, humidity_scaled)) + math.min(15, heat_scaled)))
end

local function grass_after_place (pos, placer, itemstack, pointed_thing)
	if placer: get_player_control().sneak then
		local node = minetest.get_node(pos)
		node.param2 = 136
		minetest.set_node(pos, node)
		
		local meta = minetest.get_meta(pos)
		meta: set_string('awg:no_recolor', 'true')
		
		return
	end
	
	local node = minetest.get_node(pos)
	node.param2 = awg.get_biome_color(pos)
	minetest.set_node(pos, node)
end

etc.smart_override_item('default:dirt', {groups = {dirt = 1}})
etc.smart_override_item('default:dry_dirt', {groups = {dirt = 1}})
etc.smart_override_item('default:dirt_with_coniferous_litter', {groups = {dirt = 1}})
etc.smart_override_item('default:dirt_with_rainforest_litter', {groups = {dirt = 1}})
etc.smart_override_item('default:dirt_with_snow', {groups = {dirt = 1}})
etc.smart_override_item('default:sand', {groups = {sand = 1}})
etc.smart_override_item('default:silver_sand', {groups = {sand = 1}})
etc.smart_override_item('default:desert_sand', {groups = {sand = 1}})
etc.smart_override_item('default:gravel', {groups = {gravel = 1}})

etc.smart_override_item('default:dirt_with_grass', {
	tiles = {
		{name = 'awg_grass.png'},
		{name = 'default_dirt.png', color = 'white'},
		{name = 'default_dirt.png', color = 'white'}
	},
	overlay_tiles = {
		'',
		'',
		'awg_grass_side.png'
	},
	use_texture_alpha = 'blend',
	paramtype2 = 'color',
	color = '#4AA432',
	palette = 'awg_grass_colormap.png',
	after_place_node = grass_after_place
})

awg: inherit_item('default:dirt_with_grass', 'dry_dirt_with_grass', {
	displayname = 'Savanna Dirt with Grass',
	description = '',
	tiles = {
		'awg_grass.png',
		{name = 'default_dry_dirt.png', color = 'white'},
		{name = 'default_dry_dirt.png', color = 'white'}
	},
	groups = {crumbly = 3, soil = 1},
	drop = 'default:dry_dirt'
})

minetest.register_abm {
	label = 'Grass Color Update',
	nodenames = {
		'default:dirt_with_grass',
		'always_greener:dry_dirt_with_grass'
	},
	interval = 30,
	chance = 10,
	catch_up = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		if meta: get_string 'awg:no_recolor' == 'true' then return end
		
		node.param2 = awg.get_biome_color(pos)
		minetest.swap_node(pos, node)
	end
}

local dead_grass = minetest.settings: get_bool('awg.dead_grass', true)

if dead_grass then
	awg: inherit_item('default:dirt_with_grass', 'dirt_with_dead_grass', {
		displayname = 'Dirt with Dead Grass',
		description = '',
		groups = {crumbly = 3, soil = 1, spreading_dirt_type = 0},
		palette = 'awg_dead_grass_colormap.png',
		color = '#594a28',
		tiles = {
			{name = 'default_dirt.png', color = 'white'},
			{name = 'default_dirt.png', color = 'white'},
			{name = 'default_dirt.png', color = 'white'}
		},
		overlay_tiles = {
			'awg_dead_grass.png',
			'',
			'awg_dead_grass_side.png'
		}
	})

	awg: inherit_item('always_greener:dry_dirt_with_grass', 'dry_dirt_with_dead_grass', {
		displayname = 'Savanna Dirt with Dead Grass',
		description = '',
		groups = {crumbly = 3, soil = 1, spreading_dirt_type = 0},
		palette = 'awg_dead_grass_colormap.png',
		color = '#594a28',
		tiles = {
			{name = 'default_dry_dirt.png', color = 'white'},
			{name = 'default_dry_dirt.png', color = 'white'},
			{name = 'default_dry_dirt.png', color = 'white'}
		},
		overlay_tiles = {
			'awg_dead_grass.png',
			'',
			'awg_dead_grass_side.png'
		},
		drop = 'default:dry_dirt'
	})
end

local caught = 0

for i, abm in pairs(minetest.registered_abms) do
	if caught == 2 then break end
	
	if abm.label == 'Grass covered' then
		caught = caught + 1
		
		if dead_grass then
			abm.action = function(pos, node)
				local above = pos + vector.new(0, 1, 0)
				local name = minetest.get_node(above).name
				local def = minetest.registered_nodes[name]
				if name ~= 'ignore' and def and not (def.sunlight_propagates or def.paramtype == 'light') then
					if node.name == 'always_greener:dry_dirt_with_grass' then
						minetest.set_node(pos, {name = 'always_greener:dry_dirt_with_dead_grass', param2 = awg.get_biome_color(pos)})
					else
						minetest.set_node(pos, {name = 'always_greener:dirt_with_dead_grass', param2 = awg.get_biome_color(pos)})
					end
				end
			end
		end
	end
	
	if abm.label == 'Grass spread' then
		caught = caught + 1
		
		abm.action = function(pos, node)
			local above = pos + vector.new(0, 1, 0)
			if (minetest.get_node_light(above) or 0) < 13 then return end
			
			local pos2 = minetest.find_node_near(pos, 1, 'group:spreading_dirt_type')
			if pos2 then
				local near_node = minetest.get_node(pos2)
				near_node.param2 = awg.get_biome_color(pos)
				minetest.set_node(pos, near_node)
				return
			end

			local name = minetest.get_node(above).name
			if name == 'default:snow' then
				minetest.set_node(pos, {name = 'default:dirt_with_snow'})
			elseif minetest.get_item_group(name, 'grass') + minetest.get_item_group(name, 'dry_grass') ~= 0 then
				minetest.set_node(pos, {name = 'default:dirt_with_grass', param2 = awg.get_biome_color(pos)})
			end
		end
	end
end

minetest.register_abm {
	label = 'Dead Grass to Dirt',
	nodenames = {
		'always_greener:dirt_with_dead_grass',
		'always_greener:dry_dirt_with_dead_grass'
	},
	interval = 30,
	chance = 15,
	catch_up = true,
	action = function(pos, node)
		if node.name == 'always_greener:dry_dirt_with_dead_grass' then
			node.param2 = awg.get_biome_color(pos)
			node.name = 'default:dry_dirt'
		else
			node.name = 'default:dirt'
		end
		
		minetest.swap_node(pos, node)
	end
}

minetest.register_decoration({
	deco_type = 'simple',
	decoration = 'default:dirt_with_grass',
	place_on = {'default:dirt_with_rainforest_litter', 'default:dirt_with_coniferous_litter'},
	place_offset_y = -1,
	sidelen = 4,
	noise_params = {
		offset = -1.5,
		scale = 1.5,
		spread = {x = 200, y = 200, z = 200},
		seed = 241,
		octaves = 4,
		persist = 1.0
	},
	y_max = 31000,
	y_min = 1,
	flags = 'force_placement'
})

local function tallgrass_after_place (name) return function (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.name = name .. math.random(1, 7)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end end

for i = 1, 5 do
	etc.smart_override_item('default:dry_grass_'..i, {
		drawtype = 'mesh',
		mesh = 'awg_grass.obj',
		tiles = {'awg_grass_'..i..'.png'},
		inventory_overlay = 'awg_dry_grass_inv.png',
		inventory_image = 'empty.png',
		paramtype2 = 'degrotate',
		color = '#d0c256',
		floodable = true,
		after_place_node = tallgrass_after_place 'default:dry_grass_',
		groups = {plant = 1}
	}, {'wield_image', 'on_place'})
end

for i = 1, 5 do
	etc.smart_override_item('default:grass_'..i, {
		drawtype = 'mesh',
		mesh = 'awg_grass.obj',
		tiles = {'awg_grass_'..i..'.png'},
		inventory_overlay = 'awg_grass_inv.png',
		inventory_image = 'empty.png',
		paramtype2 = 'degrotate',
		color = '#82a433',
		floodable = true,
		after_place_node = tallgrass_after_place 'default:grass_',
		groups = {plant = 1}
	}, {'wield_image', 'on_place'})
end

awg: inherit_item('default:grass_5', 'grass_6', {
	description = '',
	mesh = 'awg_grass_2.obj',
	tiles = {'awg_grass_6.png'}
})
minetest.register_alias('default:grass_6', 'always_greener:grass_6')

awg: inherit_item('default:grass_5', 'grass_7', {
	description = '',
	mesh = 'awg_grass_2.obj',
	tiles = {'awg_grass_7.png'}
})
minetest.register_alias('default:grass_7', 'always_greener:grass_7')

awg: inherit_item('default:dry_grass_5', 'dry_grass_6', {
	description = '',
	mesh = 'awg_grass_2.obj',
	tiles = {'awg_grass_6.png'}
})
minetest.register_alias('default:dry_grass_6', 'always_greener:dry_grass_6')

awg: inherit_item('default:dry_grass_5', 'dry_grass_7', {
	description = '',
	mesh = 'awg_grass_2.obj',
	tiles = {'awg_grass_7.png'}
})
minetest.register_alias('default:dry_grass_7', 'always_greener:dry_grass_7')

minetest.register_decoration({
	name = 'default:grass_6',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = -0.045,
		scale = 0.1,
		spread = {x = 300, y = 300, z = 300},
		seed = 209,
		octaves = 3,
		persist = 0.8
	},
	biomes = {'grassland', 'deciduous_forest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:grass_6',
	param2 = 0,
	param2_max = 239
})

minetest.register_decoration({
	name = 'default:grass_7',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = -0.05,
		scale = 0.12,
		spread = {x = 300, y = 300, z = 300},
		seed = 44,
		octaves = 3,
		persist = 0.8
	},
	biomes = {'grassland', 'deciduous_forest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:grass_7',
	param2 = 0,
	param2_max = 239
})

minetest.register_decoration({
	name = 'default:grass_3_2',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass'},
	sidelen = 16,
	fill_ratio = 0.75,
	biomes = {'grassland'},
	y_max = 31000,
	y_min = 1,
	decoration = 'default:grass_3',
	param2 = 0,
	param2_max = 239
})

minetest.register_decoration({
	name = 'default:dry_grass_6',
	deco_type = 'simple',
	place_on = {'always_greener:dry_dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = -0.045,
		scale = 0.2,
		spread = {x = 600, y = 600, z = 600},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {'savanna'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:dry_grass_6',
	param2 = 0,
	param2_max = 239
})

minetest.register_decoration({
	name = 'default:dry_grass_7',
	deco_type = 'simple',
	place_on = {'always_greener:dry_dirt_with_grass'},
	sidelen = 16,
	noise_params = {
		offset = -0.05,
		scale = 0.3,
		spread = {x = 600, y = 600, z = 600},
		seed = 812,
		octaves = 3,
		persist = 0.6
	},
	biomes = {'savanna'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:dry_grass_7',
	param2 = 0,
	param2_max = 239
})

minetest.register_decoration({
	name = 'default:dry_grass_3_2',
	deco_type = 'simple',
	place_on = {'always_greener:dry_dirt_with_grass'},
	sidelen = 16,
	fill_ratio = 0.75,
	biomes = {'savanna'},
	y_max = 31000,
	y_min = 1,
	decoration = 'default:dry_grass_3',
	param2 = 0,
	param2_max = 239
})

etc.smart_override_item('default:junglegrass', {
	drawtype = 'mesh',
	mesh = 'awg_jungle_grass.obj',
	tiles = {'awg_jungle_grass.png'},
	inventory_image = 'awg_jungle_grass_inv.png',
	paramtype2 = 'degrotate',
	visual_scale = 1,
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		node.param2 = math.random(0, 239)
		minetest.swap_node(pos, node)
	end,
	groups = {plant = 1}
}, {'wield_image'})

awg: inherit_item('default:junglegrass', 'jungle_grass_flowering', {
	tiles = {'awg_jungle_grass_flower.png'},
	displayname = 'Flowering Jungle Grass',
	description = '',
	drop = 'always_greener:jungle_grass_flowering',
	inventory_image = 'awg_jungle_grass_flower_inv.png'
})

minetest.register_decoration({
	name = 'default:junglegrass_flowering',
	deco_type = 'simple',
	place_on = {'default:dirt_with_rainforest_litter'},
	sidelen = 80,
	fill_ratio = 0.05,
	biomes = {'rainforest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:jungle_grass_flowering',
	param2 = 0,
	param2_max = 239
})

awg: inherit_item('default:junglegrass', 'jungle_grass_short', {
	tiles = {'awg_jungle_grass_short.png'},
	groups = {not_in_creative_inventory = 1},
	drop = 'default:junglegrass',
	displayname = 'Stubby Jungle Grass',
	description = ''
})

minetest.register_decoration({
	name = 'default:junglegrass_short',
	deco_type = 'simple',
	place_on = {'default:dirt_with_rainforest_litter'},
	sidelen = 80,
	fill_ratio = 0.25,
	biomes = {'rainforest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:jungle_grass_short',
	param2 = 0,
	param2_max = 239
})

if etc.modules.farming_tweaks then
	etc.farming_tweaks.compost_values['always_greener:jungle_grass_flowering'] = 9
end

minetest.register_craft {
	type = 'shapeless',
	output = 'dye:magenta 4',
	recipe = {'always_greener:jungle_grass_flowering'}
}

if etc.modules.mortar_and_pestle then
	etc.register_mortar_recipe('always_greener:jungle_grass_flowering', 'dye:magenta 8', 3, true)
end
