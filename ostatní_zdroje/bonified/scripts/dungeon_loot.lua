
-- Regular bones
dungeon_loot.register {
	{name = 'bonified:bone', chance = 0.4, count = {1, 3}},
	{name = 'bonified:bone', chance = 0.1, count = {5, 9}},
	{name = 'bonified:bone', chance = 0.5, count = {1, 5}, types = {'ice'}},
	{name = 'bonified:bone', chance = 0.2, count = {4, 12}, types = {'ice'}}
}

-- Bone meal
dungeon_loot.register {
	{name = 'bonified:bone_meal', chance = 0.3, count = {2, 6}},
	{name = 'bonified:bone_meal', chance = 0.1, count = {4, 16}}
}

-- Bone tools
if core.settings: get_bool('bonified.enable_bone_tools', true) then
	dungeon_loot.register {
		{name = 'bonified:tool_pick_bone', chance = 0.15},
		{name = 'bonified:tool_shovel_bone', chance = 0.1},
		{name = 'bonified:tool_axe_bone', chance = 0.15},
		{name = 'bonified:tool_sword_bone', chance = 0.09}
	}
end

-- Fossils
dungeon_loot.register {
	{name = 'bonified:fossil', chance = 0.08, count = {1, 3}},
	{name = 'bonified:fossil', chance = 0.02, count = {4, 6}},
	{name = 'bonified:fossil', chance = 0.1, count = {1, 3}, types = {'ice'}},
	{name = 'bonified:fossil', chance = 0.05, count = {4, 6}, types = {'ice'}}
}

-- Fossil tools
if core.settings: get_bool('bonified.enable_fossil_tools', true) then
	dungeon_loot.register {
		{name = 'bonified:tool_pick_fossil', chance = 0.05, y = {-32768, -300}},
		{name = 'bonified:tool_shovel_fossil', chance = 0.06, y = {-32768, -300}},
		{name = 'bonified:tool_axe_fossil', chance = 0.06, y = {-32768, -300}},
		{name = 'bonified:tool_sword_fossil', chance = 0.05, y = {-32768, -300}}
	}
end

-- Bone armor
if core.settings: get_bool('bonified.enable_armor', true) and
core.settings: get_bool('bonified.enable_bone_tools', true) then
	dungeon_loot.register {
		{name = 'bonified:armor_helmet_bone', chance = 0.1},
		{name = 'bonified:armor_chestplate_bone', chance = 0.08},
		{name = 'bonified:armor_leggings_bone', chance = 0.08},
		{name = 'bonified:armor_boots_bone', chance = 0.1},
		{name = 'bonified:armor_shield_bone', chance = 0.08}
	}
end

-- Fossil armor
if core.settings: get_bool('bonified.enable_armor', true) and
core.settings: get_bool('bonified.enable_fossil_tools', true) then
	dungeon_loot.register {
		{name = 'bonified:armor_helmet_fossil', chance = 0.075, y = {-32768, -300}},
		{name = 'bonified:armor_chestplate_fossil', chance = 0.05, y = {-32768, -300}},
		{name = 'bonified:armor_leggings_fossil', chance = 0.05, y = {-32768, -300}},
		{name = 'bonified:armor_boots_fossil', chance = 0.075, y = {-32768, -300}},
		{name = 'bonified:armor_shield_fossil', chance = 0.05, y = {-32768, -300}}
	}
end
