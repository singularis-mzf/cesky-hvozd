local S = core.get_translator 'bonified'

core.register_craftitem('bonified:fossil', {
	description = S 'Ancient Fossil',
	inventory_image = 'bonified_fossil.png'
})

local stone_fossil_def = table.copy(core.registered_nodes['default:stone'])
stone_fossil_def.tiles[1] = stone_fossil_def.tiles[1] .. '^bonified_fossil_ore.png'
stone_fossil_def.description = S 'Stone with Fossils'
stone_fossil_def.type = nil
stone_fossil_def.drop = {
	max_items = 3,
	items = {
		{items = {'bonified:fossil 2'}, rarity = 9},
		{items = {'bonified:bone 3'}, rarity = 6},
		{items = {'bonified:fossil'}, rarity = 5},
		{items = {'bonified:fossil'}, rarity = 3},
		{items = {'bonified:bone 2'}}
	}
}
core.register_node('bonified:stone_with_fossil', stone_fossil_def)

core.register_ore {
	ore_type       = 'scatter',
	ore            = 'bonified:stone_with_fossil',
	wherein        = 'default:stone',
	clust_scarcity = 24^3,
	clust_num_ores = 4,
	clust_size     = 3,
	y_max          = -150,
	y_min          = -300
}

local permafrost_fossil_def = table.copy(core.registered_nodes['default:permafrost'])
permafrost_fossil_def.tiles[1] = permafrost_fossil_def.tiles[1] .. '^bonified_fossil_ore.png'
permafrost_fossil_def.description = S 'Permafrost with Fossils'
permafrost_fossil_def.type = nil
permafrost_fossil_def.drop = {
	max_items = 3,
	items = {
		{items = {'bonified:fossil 2'}, rarity = 9},
		{items = {'bonified:bone 3'}, rarity = 6},
		{items = {'bonified:fossil'}, rarity = 5},
		{items = {'bonified:fossil'}, rarity = 3},
		{items = {'bonified:bone 2'}}
	}
}
core.register_node('bonified:permafrost_with_fossil', permafrost_fossil_def)

core.register_ore {
	ore_type       = 'scatter',
	ore            = 'bonified:permafrost_with_fossil',
	wherein        = {'default:permafrost', 'default:permafrost_with_stones'},
	clust_scarcity = 32^3,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = 80,
	y_min          = 0
}

-- Fossil meal
if core.settings: get_bool('bonified.enable_bone_meal', true) then
	core.register_craftitem('bonified:fossil_meal', {
		description = S 'Fossil Meal',
		inventory_image = 'bonified_fossil_meal.png',
		on_use = bonified.apply_fertilizer(core.settings: get 'bonified.fossil_meal_strength' or 0.95)
	})

	core.register_craft {
		type = 'shapeless',
		output = 'bonified:fossil_meal 4',
		recipe = {'bonified:fossil'}
	}
end

-- Fossil block
core.register_node('bonified:fossil_block', {
	description = S 'Fossil Block',
	tiles = {'bonified_fossil_block.png'},
	groups = {oddly_breakable_by_hand = 1, crumbly = 3},
	sounds = default.node_sound_gravel_defaults()
})

core.register_craft {
	type = 'shapeless',
	output = 'bonified:fossil 4',
	recipe = {'bonified:fossil_block'}
}

core.register_craft {
	output = 'bonified:fossil_block',
	recipe = {
		{'bonified:fossil', 'bonified:fossil'},
		{'bonified:fossil', 'bonified:fossil'}
	}
}
