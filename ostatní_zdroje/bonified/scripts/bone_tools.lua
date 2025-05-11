local S = core.get_translator 'bonified'

-- The gimmick of bone tools is they have similar durability to steel and start out slightly worse,
-- but as they wear down they become more effective.
local last_bt_update = os.time()
-- This callback is to check the wear of each players' currently held bone tool (if present),
-- and set the capabilities appropriately.
core.register_globalstep(function (dtime)
	if os.time() - last_bt_update >= 1.5 then
		for _, player in ipairs(core.get_connected_players()) do
			local itemstack = player: get_wielded_item()
			if core.get_item_group(itemstack: get_name(), 'bone_tool') ~= 0 then
				-- Approaches 0.5 as wear approaches 65535
				local wear_diff_ratio_inverse = (65535 - (itemstack: get_wear() * 0.5)) / 65535
				-- Approaches 2 as wear maxes out
				local wear_diff_ratio = 1 / wear_diff_ratio_inverse
				
				local caps = itemstack: get_definition().tool_capabilities
				
				local new_groupcaps = {}
				for name, group in pairs(caps.groupcaps) do
					local new_times = {}
					
					for i, t in ipairs(group.times) do
						new_times[i] = t * wear_diff_ratio_inverse -- Reduce digtime
					end
					
					new_groupcaps[name] = {times = new_times, uses = group.uses, maxlevel = group.maxlevel}
				end
				
				local new_damage_groups = {}
				for group, rating in pairs(caps.damage_groups) do
					new_damage_groups[group] = math.floor((rating * wear_diff_ratio) + 0.5) -- increase damage
				end
				
				itemstack: get_meta(): set_tool_capabilities {
					max_drop_level = caps.max_drop_level,
					full_punch_interval = caps.full_punch_interval * wear_diff_ratio_inverse, -- reduce swing delay
					groupcaps = new_groupcaps,
					damage_groups = new_damage_groups
				}
				
				player: set_wielded_item(itemstack)
			end
		end
		
		last_bt_update = os.time()
	end
end)

function bonified.register_bone_tool(name, def)
	def.groups = def.groups or {}
	def.groups.bone_tool = 1
	
	def.wear_color = {
		blend = 'linear',
		color_stops = {
			[0.0] = '#ff0044',
			[0.5] = '#ff9539',
			[1.0] = '#ffe5a4'
		}
	}
	
	core.register_tool(name, def)
end

bonified.register_bone_tool('bonified:tool_pick_bone', {
	description = S 'Bone Pickaxe',
	inventory_image = 'bonified_pick_bone.png',
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.50, [2]=1.80, [3]=0.90}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {pickaxe = 1}
})

core.register_craft {
	output = 'bonified:tool_pick_bone',
	recipe = {
		{'bonified:bone_block', 'bonified:bone_block', 'bonified:bone_block'},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''}
	}
}

bonified.register_bone_tool('bonified:tool_shovel_bone', {
	description = S 'Bone Shovel',
	inventory_image = 'bonified_shovel_bone.png',
	wield_image = 'bonified_shovel_bone.png^[transformR90',
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.65, [2]=1.05, [3]=0.45}, uses=35, maxlevel=2},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {shovel = 1}
})

core.register_craft {
	output = 'bonified:tool_shovel_bone',
	recipe = {
		{'', 'bonified:bone_block', ''},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''}
	}
}

bonified.register_bone_tool('bonified:tool_axe_bone', {
	description = S 'Bone Axe',
	inventory_image = 'bonified_axe_bone.png',
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.75, [2]=1.70, [3]=1.15}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {axe = 1}
})

core.register_craft {
	output = 'bonified:tool_axe_bone',
	recipe = {
		{'bonified:bone_block', 'bonified:bone_block', ''},
		{'bonified:bone_block', 'default:stick', ''},
		{'', 'default:stick', ''}
	}
}

bonified.register_bone_tool('bonified:tool_sword_bone', {
	description = S 'Bone Sword',
	inventory_image = 'bonified_sword_bone.png',
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.75, [2]=1.30, [3]=0.375}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=6},
	},
	sound = {breaks = 'default_tool_breaks'},
	groups = {sword = 1}
})

core.register_craft {
	output = 'bonified:tool_sword_bone',
	recipe = {
		{'', 'bonified:bone_block', ''},
		{'', 'bonified:bone_block', ''},
		{'', 'default:stick', ''}
	}
}
