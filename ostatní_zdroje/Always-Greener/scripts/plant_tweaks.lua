
etc.smart_override_item('farming:wheat_7', {
	drawtype = 'mesh',
	mesh = 'awg_wheat.obj',
})

etc.smart_override_item('farming:wheat_8', {
	drawtype = 'mesh',
	mesh = 'awg_wheat.obj',
})

for i = 1, 8 do
	etc.smart_override_item('farming:cotton_'..i, {
		paramtype2 = 'meshoptions',
		place_param2 = 4
	})
end

etc.smart_override_item('farming:seed_cotton', {
	place_param2 = 4
})

local function fern_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.name = 'default:fern_' .. math.random(1, 4)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

etc.smart_override_item('default:fern_1', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_fern.obj',
	tiles = {'awg_fern_1.png'},
	after_place_node = fern_after_place,
	inventory_image = 'awg_fern_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('default:fern_2', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_fern.obj',
	tiles = {'awg_fern_2.png'},
	visual_scale = 1,
	after_place_node = fern_after_place,
	groups = {plant = 1}
})

etc.smart_override_item('default:fern_3', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_fern.obj',
	tiles = {'awg_fern_3.png'},
	visual_scale = 1,
	after_place_node = fern_after_place,
	groups = {plant = 1}
})

awg: inherit_item('default:fern_3', 'fern_4', {
	description = '',
	mesh = 'awg_fern_2.obj',
	tiles = {'awg_fern_3.png', 'awg_fern_frond.png'}
})
minetest.register_alias('default:fern_4', 'always_greener:fern_4')

minetest.register_decoration({
	name = 'default:fern_4',
	deco_type = 'simple',
	place_on = {'default:dirt_with_coniferous_litter'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.2,
		spread = {x = 100, y = 100, z = 100},
		seed = 92837465,
		octaves = 3,
		persist = 0.7
	},
	biomes = {'coniferous_forest'},
	y_max = 31000,
	y_min = 6,
	decoration = 'default:fern_4',
	param2 = 0,
	param2_max = 239
})

local function flower_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

etc.smart_override_item('flowers:geranium', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_geranium.obj',
	tiles = {'awg_geranium.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_geranium_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:chrysanthemum_green', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_chrysanthemum.obj',
	tiles = {'awg_chrysanthemum.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_chrysanthemum_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:dandelion_yellow', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_dandelion.obj',
	tiles = {'awg_dandelion_yellow.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_dandelion_yellow_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:dandelion_white', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_dandelion.obj',
	tiles = {'awg_dandelion_white.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_dandelion_white_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:viola', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_viola.obj',
	tiles = {'awg_viola.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_viola_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:tulip', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_tulip.obj',
	tiles = {'awg_tulip_orange.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_tulip_orange_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:tulip_black', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_tulip.obj',
	tiles = {'awg_tulip_black.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_tulip_black_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('flowers:rose', {
	drawtype = 'mesh',
	paramtype2 = 'degrotate',
	mesh = 'awg_rose.obj',
	tiles = {'awg_rose.png'},
	after_place_node = flower_after_place,
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_rose_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

minetest.register_alias('flowers:mushroom_brown_1', 'flowers:mushroom_brown')

etc.smart_override_item('flowers:mushroom_brown', {
	tiles = {'awg_mushroom_brown_top.png', 'awg_mushroom_bottom.png', 'awg_mushroom_brown_side.png'},
	use_texture_alpha = 'clip',
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		node.name = 'flowers:mushroom_brown_' .. math.random(1, 3)
		minetest.swap_node(pos, node)
	end,
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.75/16, -0.5, -0.75/16, 0.75/16, -5/16, 0.75/16},
			{-3/16, -5/16, -3/16, 3/16, -3/16, 3/16}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.75/16, -0.5, -0.75/16, 0.75/16, -5/16, 0.75/16},
			{-3/16, -5/16, -3/16, 3/16, -3/16, 3/16}
		}
	},
	inventory_image = 'awg_mushroom_brown_inv.png',
	wield_image = 'awg_mushroom_brown_inv.png'
})

awg: inherit_item('flowers:mushroom_brown', 'mushroom_brown_2', {
	description = '',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.25, -0.5, 0, -0.1875, -0.3125, 0.0625},
			{-0.293244, -0.3125, -0.0423193, -0.144256, -0.1875, 0.104819},
			{0.167545, -0.5, -0.236672, 0.230045, -0.3125, -0.174172},
			{0.066265, -0.311898, -0.344578, 0.331325, -0.186898, -0.0674699}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.25, -0.5, 0, -0.1875, -0.3125, 0.0625},
			{-0.293244, -0.3125, -0.0423193, -0.144256, -0.1875, 0.104819},
			{0.167545, -0.5, -0.236672, 0.230045, -0.3125, -0.174172},
			{0.066265, -0.311898, -0.344578, 0.331325, -0.186898, -0.0674699}
		}
	},
	drop = 'flowers:mushroom_brown',
	groups = {not_in_creative_inventory = 1}
})
minetest.register_alias('flowers:mushroom_brown_2', 'always_greener:mushroom_brown_2')

awg: inherit_item('flowers:mushroom_brown', 'mushroom_brown_3', {
	description = '',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.317849, -0.5, -0.186145, -0.225525, -0.314458, -0.0921687},
			{-0.425084, -0.313253, -0.3, -0.11829, -0.166265, 0.0180723},
			{-0.231704, -0.5, 0.264458, -0.13938, -0.314458, 0.358434},
			{0.232151, -0.5, -0.358434, 0.324475, -0.314458, -0.264458},
			{0.252031, -0.5, 0.178313, 0.344355, -0.314458, 0.271084},
			{0.170204, -0.313253, 0.0995694, 0.404501, -0.166265, 0.336047}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.317849, -0.5, -0.186145, -0.225525, -0.314458, -0.0921687},
			{-0.425084, -0.313253, -0.3, -0.11829, -0.166265, 0.0180723},
			{-0.231704, -0.5, 0.264458, -0.13938, -0.314458, 0.358434},
			{0.232151, -0.5, -0.358434, 0.324475, -0.314458, -0.264458},
			{0.252031, -0.5, 0.178313, 0.344355, -0.314458, 0.271084},
			{0.170204, -0.313253, 0.0995694, 0.404501, -0.166265, 0.336047}
		}
	},
	drop = 'flowers:mushroom_brown',
	groups = {not_in_creative_inventory = 1}
})
minetest.register_alias('flowers:mushroom_brown_3', 'always_greener:mushroom_brown_3')

minetest.register_decoration({
	name = 'always_greener:mushroom_brown_2',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass', 'default:dirt_with_coniferous_litter'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'deciduous_forest', 'coniferous_forest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:mushroom_brown_2',
})

minetest.register_decoration({
	name = 'always_greener:mushroom_brown_3',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass', 'default:dirt_with_coniferous_litter'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'deciduous_forest', 'coniferous_forest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:mushroom_brown_3',
})

minetest.register_alias('flowers:mushroom_red_1', 'flowers:mushroom_red')

etc.smart_override_item('flowers:mushroom_red', {
	tiles = {'awg_mushroom_red_top.png', 'awg_mushroom_bottom.png', 'awg_mushroom_red_side.png'},
	use_texture_alpha = 'clip',
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		node.name = 'flowers:mushroom_red_' .. math.random(1, 3)
		minetest.swap_node(pos, node)
	end,
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.0560078, -0.5, -0.0622309, 0.0560078, -0.25, 0.0622309},
			{-0.167337, -0.260098, -0.173494, 0.173107, -0.172669, 0.173494},
			{-0.121175, -0.17643, -0.130685, 0.126945, -0.089001, 0.130685}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.0560078, -0.5, -0.0622309, 0.0560078, -0.25, 0.0622309},
			{-0.167337, -0.260098, -0.173494, 0.173107, -0.172669, 0.173494},
			{-0.121175, -0.17643, -0.130685, 0.126945, -0.089001, 0.130685}
		}
	},
	inventory_image = 'awg_mushroom_red_inv.png',
	wield_image = 'awg_mushroom_red_inv.png'
})

awg: inherit_item('flowers:mushroom_red', 'mushroom_red_2', {
	description = '',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.205362, -0.5, 0.273816, -0.118239, -0.24812, 0.360939},
			{-0.268316, -0.25, 0.204635, -0.0548172, -0.11829, 0.43012},
			{-0.236579, -0.12406, 0.229936, -0.0807832, -0.0506024, 0.404819},
			{0.211585, -0.5, 1.3411e-07, 0.298708, -0.24812, 0.0871232},
			{0.167052, -0.25, -0.0393827, 0.346214, -0.147141, 0.126506},
			{-0.222477, -0.5, -0.308622, -0.135354, -0.24812, -0.221499},
			{-0.28423, -0.252885, -0.4, -0.0331325, -0.115663, -0.130121}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.205362, -0.5, 0.273816, -0.118239, -0.24812, 0.360939},
			{-0.268316, -0.25, 0.204635, -0.0548172, -0.11829, 0.43012},
			{-0.236579, -0.12406, 0.229936, -0.0807832, -0.0506024, 0.404819},
			{0.211585, -0.5, 1.3411e-07, 0.298708, -0.24812, 0.0871232},
			{0.167052, -0.25, -0.0393827, 0.346214, -0.147141, 0.126506},
			{-0.222477, -0.5, -0.308622, -0.135354, -0.24812, -0.221499},
			{-0.28423, -0.252885, -0.4, -0.0331325, -0.115663, -0.130121}
		}
	},
	drop = 'flowers:mushroom_red',
	groups = {not_in_creative_inventory = 1}
})
minetest.register_alias('flowers:mushroom_red_2', 'always_greener:mushroom_red_2')

awg: inherit_item('flowers:mushroom_red', 'mushroom_red_3', {
	description = '',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.185095, -0.5, -0.255422, -0.0004474, -0.24235, -0.0891566},
			{-0.314292, -0.246617, -0.387952, 0.135415, -0.0995968, 0.0433735},
			{-0.24812, -0.102426, -0.313253, 0.0634725, 0.0445944, -0.0120482},
			{0.236286, -0.5, 0.0180724, 0.386605, -0.242169, 0.140964},
			{0.173107, -0.24432, -0.0650602, 0.450078, -0.0634725, 0.224096}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{-0.185095, -0.5, -0.255422, -0.0004474, -0.24235, -0.0891566},
			{-0.314292, -0.246617, -0.387952, 0.135415, -0.0995968, 0.0433735},
			{-0.24812, -0.102426, -0.313253, 0.0634725, 0.0445944, -0.0120482},
			{0.236286, -0.5, 0.0180724, 0.386605, -0.242169, 0.140964},
			{0.173107, -0.24432, -0.0650602, 0.450078, -0.0634725, 0.224096}
		}
	},
	drop = 'flowers:mushroom_red',
	groups = {not_in_creative_inventory = 1}
})
minetest.register_alias('flowers:mushroom_red_3', 'always_greener:mushroom_red_3')

minetest.register_decoration({
	name = 'always_greener:mushroom_red_2',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass', 'default:dirt_with_coniferous_litter'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'deciduous_forest', 'coniferous_forest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:mushroom_red_2',
})

minetest.register_decoration({
	name = 'always_greener:mushroom_red_3',
	deco_type = 'simple',
	place_on = {'default:dirt_with_grass', 'default:dirt_with_coniferous_litter'},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {'deciduous_forest', 'coniferous_forest'},
	y_max = 31000,
	y_min = 1,
	decoration = 'always_greener:mushroom_red_3',
})

etc.smart_override_item('default:coral_cyan', {
	drawtype = 'mesh',
	mesh = 'awg_coral_cyan.obj',
	tiles = {'default_coral_skeleton.png', 'awg_coral_cyan.png'},
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_coral_cyan_inv.png',
	wield_image = 'awg_coral_cyan_inv.png',
	node_placement_prediction = '',
	node_dig_prediction = 'default:coral_skeleton'
})

etc.smart_override_item('default:coral_pink', {
	drawtype = 'mesh',
	mesh = 'awg_coral_pink.obj',
	tiles = {'default_coral_skeleton.png', 'awg_coral_pink.png'},
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_coral_pink_inv.png',
	wield_image = 'awg_coral_pink_inv.png',
	node_placement_prediction = '',
	node_dig_prediction = 'default:coral_skeleton'
})

etc.smart_override_item('default:coral_green', {
	drawtype = 'mesh',
	mesh = 'awg_coral_green.obj',
	tiles = {'default_coral_skeleton.png', 'awg_coral_green.png'},
	use_texture_alpha = 'clip',
	waving = 0,
	inventory_image = 'awg_coral_green_inv.png',
	wield_image = 'awg_coral_green_inv.png',
	node_placement_prediction = '',
	node_dig_prediction = 'default:coral_skeleton'
})

etc.smart_override_item('flowers:waterlily_waving', {
	tiles = {'awg_water_lily.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_water_lily.obj',
	paramtype2 = 'degrotate',
	drop = 'flowers:waterlily',
	groups = {plant = 1}
})

etc.smart_override_item('flowers:waterlily', {
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local def = minetest.registered_nodes[node.name]

		if def and def.on_rightclick then
			return def.on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing)
		end

		if def and def.liquidtype == 'source' and minetest.get_item_group(node.name, 'water') > 0 then
			local player_name = placer and placer:get_player_name() or ''
			if not minetest.is_protected(pos, player_name) then
				minetest.set_node(pos, {name = 'flowers:waterlily_waving_'..math.random(1,4), param2 = math.random(0, 239)})
				if not minetest.is_creative_enabled(player_name) then
					itemstack:take_item()
				end
			end
		end

		return itemstack
	end,
	inventory_image = 'awg_water_lily_inv.png',
	wield_image = 'awg_water_lily_inv.png',
	groups = {plant = 1}
})

minetest.register_alias('flowers:waterlily_waving_1', 'flowers:waterlily_waving')

awg: inherit_item('flowers:waterlily_waving', 'waterlily_waving_2', {
	drop = 'flowers:waterlily_waving',
	groups = {not_in_creative_inventory = 1},
	tiles = {'awg_water_lily_flower_pink.png'},
	drop = 'flowers:waterlily',
	waving = 0
})
minetest.register_alias('flowers:waterlily_waving_2', 'always_greener:waterlily_waving_2')

awg: inherit_item('flowers:waterlily_waving', 'waterlily_waving_3', {
	drop = 'flowers:waterlily_waving',
	groups = {not_in_creative_inventory = 1},
	tiles = {'awg_water_lily_flower_white.png'},
	drop = 'flowers:waterlily',
	waving = 0
})
minetest.register_alias('flowers:waterlily_waving_3', 'always_greener:waterlily_waving_3')

awg: inherit_item('flowers:waterlily_waving', 'waterlily_waving_4', {
	drop = 'flowers:waterlily_waving',
	groups = {not_in_creative_inventory = 1},
	tiles = {'awg_water_lily_small.png'},
	drop = 'flowers:waterlily',
	waving = 3
})
minetest.register_alias('flowers:waterlily_waving_4', 'always_greener:waterlily_waving_4')

etc.smart_override_item('default:papyrus', {
	tiles = {'awg_papyrus.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_papyrus.obj',
	inventory_image = 'awg_papyrus_inv.png',
	groups = {plant = 1}
}, {'wield_image'})

etc.smart_override_item('default:sand_with_kelp', {
	waving = 2,
	inventory_image = 'awg_kelp_inv.png',
	wield_image = 'awg_kelp_inv.png',
	special_tiles = {{
		name = 'awg_kelp.png',
		tileable_vertical = true,
		animation = {
			type = 'vertical_frames',
			aspect_w = 16,
			aspect_h = 16,
			length = 4
		}
	}},
	groups = {plant = 1},
	node_placement_prediction = '',
	node_dig_prediction = 'default:sand'
})

etc.smart_override_item('default:cactus', {
	tiles = {'awg_cactus.png'},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'awg_cactus.obj',
	groups = {plant = 1}
})

etc.smart_override_item('default:acacia_bush_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:acacia_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:aspen_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:blueberry_bush_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:bush_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:dry_shrub', {groups = {plant = 1}})
etc.smart_override_item('default:emergent_jungle_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:junglesapling', {groups = {plant = 1}})
etc.smart_override_item('default:marram_grass_1', {groups = {plant = 1}})
etc.smart_override_item('default:marram_grass_2', {groups = {plant = 1}})
etc.smart_override_item('default:marram_grass_3', {groups = {plant = 1}})
etc.smart_override_item('default:large_cactus_seedling', {groups = {plant = 1}})
etc.smart_override_item('default:pine_bush_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:pine_sapling', {groups = {plant = 1}})
etc.smart_override_item('default:sapling', {groups = {plant = 1}})
