
awg: register_node('vegetable_sheep', {
	displayname = 'Vegetable Sheep',
	tiles = {'awg_vegetable_sheep.png'},
	paramtype = 'light',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, -3/16, 0.5}
	},
	groups = {crumbly = 3, plant = 1},
	sounds = default.node_sound_leaves_defaults()
})

awg: inherit_item('always_greener:vegetable_sheep', 'vegetable_sheep_flowering', {
	description = '',
	tiles = {'awg_vegetable_sheep_flowering.png'},
	groups = {not_in_creative_inventory = 1},
	drop = 'always_greener:vegetable_sheep'
})

minetest.register_decoration({
	name = 'always_greener:vegetable_sheep',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_moss', 'default:permafrost_with_stones'},
	sidelen = 16,
	fill_ratio = 0.01,
	y_max = 31000,
	y_min = 1,
	decoration = {
		'always_greener:vegetable_sheep',
		'always_greener:vegetable_sheep',
		'always_greener:vegetable_sheep_flowering'
	}
})

awg: register_node('tundra_lichen', {
	displayname = 'Frost Lichen',
	tiles = {'awg_tundra_lichen.png'},
	paramtype = 'light',
	use_texture_alpha = 'clip',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	},
	groups = {snappy = 3, plant = 1},
	sounds = default.node_sound_leaves_defaults()
})

awg: inherit_item('always_greener:tundra_lichen', 'tundra_lichen_2', {
	displayname = 'Fire Lichen',
	description = '',
	tiles = {'awg_tundra_lichen_2.png'}
})

awg: inherit_item('always_greener:tundra_lichen', 'tundra_lichen_3', {
	displayname = 'Dusty Roots',
	description = '',
	tiles = {'awg_tundra_lichen_3.png'}
})

awg: inherit_item('always_greener:tundra_lichen', 'tundra_lichen_4', {
	displayname = 'Dense Moss',
	description = '',
	tiles = {'awg_tundra_lichen_4.png'},
	node_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	}
})

awg: inherit_item('always_greener:tundra_lichen', 'tundra_lichen_5', {
	displayname = 'Twine Lichen',
	description = '',
	tiles = {'awg_tundra_lichen_5.png'},
	node_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, -7/16, 0.5}
	}
})

minetest.register_decoration({
	name = 'always_greener:tundra_lichen',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_stones'},
	sidelen = 16,
	fill_ratio = 0.02,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_lichen'}
})

minetest.register_decoration({
	name = 'always_greener:tundra_lichen_2',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_moss'},
	sidelen = 16,
	fill_ratio = 0.05,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_lichen_2'}
})

minetest.register_decoration({
	name = 'always_greener:tundra_lichen_3',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_stones'},
	sidelen = 16,
	fill_ratio = 0.1,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_lichen_3'}
})

minetest.register_decoration({
	name = 'always_greener:tundra_lichen_4',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_moss'},
	sidelen = 16,
	fill_ratio = 0.35,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_lichen_4'}
})

minetest.register_decoration({
	name = 'always_greener:tundra_lichen_5',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_moss'},
	sidelen = 16,
	fill_ratio = 0.125,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_lichen_5'}
})

awg: register_node('tundra_shrub', {
	displayname = 'Brush Bush',
	tiles = {'awg_tundra_shrub.png'},
	inventory_image = 'awg_tundra_shrub.png',
	paramtype = 'light',
	use_texture_alpha = 'clip',
	drawtype = 'firelike',
	walkable = false,
	buildable_to = true,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, -0.1, 0.35}
	},
	groups = {snappy = 3, plant = 1},
	sounds = default.node_sound_leaves_defaults(),
	move_resistance = 1
})

awg: inherit_item('always_greener:tundra_shrub', 'tundra_shrub_2', {
	displayname = 'Dusty Shrub',
	description = '',
	tiles = {'awg_tundra_shrub_2.png'},
	inventory_image = 'awg_tundra_shrub_2.png',
	drawtype = 'plantlike',
	paramtype2 = 'meshoptions',
	place_param2 = 4,
	move_resistance = 0
})

awg: inherit_item('always_greener:tundra_shrub_2', 'tundra_shrub_3', {
	displayname = 'Turpentine Bush',
	description = '',
	tiles = {'awg_tundra_shrub_3.png'},
	inventory_image = 'awg_tundra_shrub_3_inv.png',
	visual_scale = 1.5,
	place_param2 = 42,
	selection_box = {
		type = 'fixed',
		fixed = {-0.35, -0.5, -0.35, 0.35, 0.5, 0.35}
	},
	damage_per_second = 1,
	move_resistance = 5
})

minetest.register_craft({
	type = 'fuel',
	recipe = 'always_greener:tundra_shrub_3',
	burntime = 30
})

awg: inherit_item('always_greener:tundra_shrub', 'tundra_shrub_4', {
	displayname = 'Moss Flowers',
	description = '',
	tiles = {'awg_tundra_shrub_4.png'},
	inventory_image = 'awg_tundra_shrub_4.png',
	move_resistance = 0
})

minetest.register_decoration({
	name = 'always_greener:tundra_shrub',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_stones'},
	sidelen = 16,
	fill_ratio = 0.01,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_shrub'}
})

minetest.register_decoration({
	name = 'always_greener:tundra_shrub_2',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_stones'},
	sidelen = 16,
	fill_ratio = 0.05,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_shrub_2'},
	param2 = 4
})

minetest.register_decoration({
	name = 'always_greener:tundra_shrub_3',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_stones'},
	sidelen = 16,
	fill_ratio = 0.0015,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_shrub_3'},
	param2 = 42
})

minetest.register_decoration({
	name = 'always_greener:tundra_shrub_4',
	deco_type = 'simple',
	place_on = {'default:permafrost_with_moss'},
	sidelen = 16,
	fill_ratio = 0.1,
	y_max = 31000,
	y_min = 1,
	decoration = {'always_greener:tundra_shrub_4'}
})

if etc.modules.farming_tweaks then
	etc.farming_tweaks.compost_values['always_greener:vegetable_sheep'] = 15
	etc.farming_tweaks.compost_values['always_greener:tundra_shrub_4'] = 3
	etc.farming_tweaks.compost_values['always_greener:tundra_shrub_3'] = 15
	etc.farming_tweaks.compost_values['always_greener:tundra_shrub_2'] = 5
	etc.farming_tweaks.compost_values['always_greener:tundra_shrub'] = 8
	etc.farming_tweaks.compost_values['always_greener:tundra_lichen_5'] = 3
	etc.farming_tweaks.compost_values['always_greener:tundra_lichen_4'] = 9
	etc.farming_tweaks.compost_values['always_greener:tundra_lichen_3'] = 3
	etc.farming_tweaks.compost_values['always_greener:tundra_lichen_2'] = 7
	etc.farming_tweaks.compost_values['always_greener:tundra_lichen'] = 7
end
