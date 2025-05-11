local S = core.get_translator 'bonified'

-- New mesh appearance for bones + rename to bone pile
core.override_item('bones:bones', {
	description = S 'Pile of Bones',
	drawtype = 'mesh',
	mesh = 'bonified_bone_pile.obj',
	tiles = {'bonified_bone_pile_base.png', 'bonified_bone_pile.png'},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	paramtype2 = '4dir',
	sunlight_propagates = true,
	
	collision_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	},
	selection_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.5/16, 0.5}
	}
})

-- Bone item
core.register_craftitem('bonified:bone', {
	description = S 'Bone',
	inventory_image = 'bonified_bone.png',
	groups = {bone = 1}
})

core.register_craft {
	type = 'shapeless',
	output = 'bonified:bone 6',
	recipe = {'bones:bones'}
}

core.register_craft {
	output = 'bones:bones',
	recipe = {
		{'bonified:bone', 'bonified:bone', 'bonified:bone'},
		{'bonified:bone', 'bonified:bone', 'bonified:bone'}
	}
}

-- Dropping bones from soils
local soils = {
	{'default:dirt', 30},
	{'default:dirt_with_grass', 30},
	{'default:dirt_with_coniferous_litter', 30},
	{'default:dirt_with_rainforest_litter', 24},
	{'default:dirt_with_snow', 30},
	{'default:dry_dirt', 26},
	{'default:dry_dirt_with_dry_grass', 26},
	{'default:gravel', 26},
	{'default:sand', 30},
	{'default:desert_sand', 24},
	{'default:silver_sand', 20},
	{'default:clay', 18},
	{'default:permafrost', 16}
}

for _, v in ipairs(soils) do
	local old_drop = core.registered_nodes[v[1]].drop
	local new_drop
	
	if old_drop then
		if type(old_drop) == 'table' then
			new_drop = table.copy(old_drop)
			
			table.insert(new_drop.items, 1, {items = {'bonified:bone 3'}, rarity = math.ceil(v[2] * 1.75)})
			table.insert(new_drop.items, 2, {items = {'bonified:bone'}, rarity = v[2]})
		else
			new_drop = {
				max_items = 1,
				items = {
					{items = {'bonified:bone 3'}, rarity = math.ceil(v[2] * 1.75)},
					{items = {'bonified:bone'}, rarity = v[2]},
					{items = {old_drop}}
				}
			}
		end
	else
		new_drop = {
			max_items = 1,
			items = {
				{items = {'bonified:bone 3'}, rarity = math.ceil(v[2] * 1.75)},
				{items = {'bonified:bone'}, rarity = v[2]},
				{items = {v[1]}}
			}
		}
	end
	
	core.override_item(v[1], {drop = new_drop})
end

-- Bone block
core.register_node('bonified:bone_block', {
	description = S 'Bone Block',
	tiles = {'bonified_bone_block.png'},
	groups = {oddly_breakable_by_hand = 1, crumbly = 3},
	sounds = default.node_sound_gravel_defaults()
})

core.register_craft {
	type = 'shapeless',
	output = 'bonified:bone 4',
	recipe = {'bonified:bone_block'}
}

core.register_craft {
	output = 'bonified:bone_block',
	recipe = {
		{'bonified:bone', 'bonified:bone'},
		{'bonified:bone', 'bonified:bone'}
	}
}
