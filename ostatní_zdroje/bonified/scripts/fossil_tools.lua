local S = core.get_translator 'bonified'

-- Fossil tools are basically just mese tools with more durability
core.register_tool('bonified:tool_pick_fossil', {
	description = S 'Ancient Pickaxe',
	inventory_image = 'bonified_pick_fossil.png',
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=50, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {pickaxe = 1}
})

core.register_craft {
	output = 'bonified:tool_pick_fossil',
	recipe = {
		{'bonified:fossil', 'bonified:fossil_block', 'bonified:fossil'},
		{'', 'bonified:bone', ''},
		{'', 'bonified:bone', ''}
	}
}

core.register_tool('bonified:tool_shovel_fossil', {
	description = S 'Ancient Shovel',
	inventory_image = 'bonified_shovel_fossil.png',
	wield_image = 'bonified_shovel_fossil.png^[transformR90',
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=3,
		groupcaps={
			crumbly = {times={[1]=1.20, [2]=0.60, [3]=0.30}, uses=50, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {shovel = 1}
})

core.register_craft {
	output = 'bonified:tool_shovel_fossil',
	recipe = {
		{'', 'bonified:fossil_block', ''},
		{'', 'bonified:bone', ''},
		{'', 'bonified:bone', ''}
	}
}

core.register_tool('bonified:tool_axe_fossil', {
	description = S 'Ancient Axe',
	inventory_image = 'bonified_axe_fossil.png',
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.20, [2]=1.00, [3]=0.60}, uses=50, maxlevel=3},
		},
		damage_groups = {fleshy=6},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {axe = 1}
})

core.register_craft {
	output = 'bonified:tool_axe_fossil',
	recipe = {
		{'bonified:fossil', 'bonified:fossil_block', ''},
		{'bonified:fossil', 'bonified:bone', ''},
		{'', 'bonified:bone', ''}
	}
}

core.register_tool('bonified:tool_sword_fossil', {
	description = S 'Ancient Sword',
	inventory_image = 'bonified_sword_fossil.png',
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=50, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {sword = 1}
})

core.register_craft {
	output = 'bonified:tool_sword_fossil',
	recipe = {
		{'', 'bonified:fossil', ''},
		{'', 'bonified:fossil_block', ''},
		{'', 'bonified:bone', ''}
	}
}
