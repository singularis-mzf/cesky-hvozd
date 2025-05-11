local S = core.get_translator 'bonified'

core.register_node('bonified:bone_bricks', {
	description = S 'Bone Bricks',
	tiles = {'bonified_bone_bricks.png'},
	groups = {oddly_breakable_by_hand = 3, cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

core.register_craft {
	output = 'bonified:bone_bricks 16',
	recipe = {
		{'bonified:bone_block', 'bonified:bone_block'},
		{'bonified:bone_block', 'bonified:bone_block'}
	}
}

core.register_node('bonified:fossil_bricks', {
	description = S 'Fossil Bricks',
	tiles = {'bonified_fossil_bricks.png'},
	groups = {oddly_breakable_by_hand = 3, cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

core.register_craft {
	output = 'bonified:fossil_bricks 24',
	recipe = {
		{'bonified:fossil_block', 'bonified:fossil_block'},
		{'bonified:fossil_block', 'bonified:fossil_block'}
	}
}

if core.get_modpath 'stairs' then
	stairs.register_stair_and_slab(
		'bone_bricks',
		'bonified:bone_bricks',
		{oddly_breakable_by_hand = 3, cracky = 3},
		{'bonified_bone_bricks.png'},
		S 'Bone Brick Stairs', S 'Bone Brick Slab',
		default.node_sound_stone_defaults(), true,
		S 'Bone Brick Stairs (Inner Corner)', S 'Bone Brick Stairs (Outer Corner)'
	)
	
	stairs.register_stair_and_slab(
		'fossil_bricks',
		'bonified:fossil_bricks',
		{cracky = 2},
		{'bonified_fossil_bricks.png'},
		S 'Fossil Brick Stairs', S 'Fossil Brick Slab',
		default.node_sound_stone_defaults(), true,
		S 'Fossil Brick Stairs (Inner Corner)', S 'Fossil Brick Stairs (Outer Corner)'
	)
end

if core.get_modpath 'walls' then
	walls.register(':bonified:bone_wall', S 'Bone Brick Wall', {'bonified_bone_bricks.png'},
		'bonified:bone_bricks', default.node_sound_stone_defaults())
		
	walls.register(':bonified:fossil_wall', S 'Fossil Brick Wall', {'bonified_fossil_bricks.png'},
		'bonified:fossil_bricks', default.node_sound_stone_defaults())
end
