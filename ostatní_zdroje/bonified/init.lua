
bonified = {modpath = core.get_modpath 'bonified'}
local S = core.get_translator 'bonified'

-- Bones, bone block, changes to MTG bones
dofile(bonified.modpath .. '/scripts/bones.lua')

-- Bonemeal & Fertilizer
if core.settings: get_bool('bonified.enable_bone_meal', true) then
	dofile(bonified.modpath .. '/scripts/bone_meal.lua')
end

-- Bone tools
if core.settings: get_bool('bonified.enable_bone_tools', true) then
	dofile(bonified.modpath .. '/scripts/bone_tools.lua')
end

-- Stone & permafrost fossils
dofile(bonified.modpath .. '/scripts/fossils.lua')

-- Fossil tools
if core.settings: get_bool('bonified.enable_fossil_tools', true) then
	dofile(bonified.modpath .. '/scripts/fossil_tools.lua')
end

-- Armor
if core.get_modpath '3d_armor' and core.settings: get_bool('bonified.enable_armor', true) then
	dofile(bonified.modpath .. '/scripts/armor.lua')
end

-- Dungeon loot
if core.get_modpath 'dungeon_loot' and core.settings: get_bool('bonified.enable_dungeon_loot', true) then
	dofile(bonified.modpath .. '/scripts/dungeon_loot.lua')
end

-- Decorative bone nodes
dofile(bonified.modpath .. '/scripts/deco_nodes.lua')
