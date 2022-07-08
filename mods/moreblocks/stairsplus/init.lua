--[[
More Blocks: Stairs+

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

-- Nodes will be called <modname>:{stair,slab,panel,micro,slope}_<subname>

local modpath = minetest.get_modpath("moreblocks").. "/stairsplus"
local S = minetest.get_translator("moreblocks")

stairsplus = {}
stairsplus.expect_infinite_stacks = false

stairsplus.recipeitems_list = {}
stairsplus.shapes_list = {}

if minetest.get_modpath("unified_inventory") then
	unified_inventory.virtual_groups.na_kp = stairsplus.recipeitems_list
end

if
	not minetest.get_modpath("unified_inventory")
	and minetest.settings:get_bool("creative_mode")
then
	stairsplus.expect_infinite_stacks = true
end

function stairsplus:prepare_groups(groups)
	local result = {}
	if groups then
		for k, v in pairs(groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "wool" and k ~= "tree" then
				result[k] = v
			end
		end
	end
	if not moreblocks.config.stairsplus_in_creative_inventory then
		result.not_in_creative_inventory = 1
	end
	return result
end

function stairsplus:register_all(modname, subname, recipeitem, fields)
	self:register_stair(modname, subname, recipeitem, fields)
	self:register_slab(modname, subname, recipeitem, fields)
	self:register_slope(modname, subname, recipeitem, fields)
	self:register_panel(modname, subname, recipeitem, fields)
	self:register_micro(modname, subname, recipeitem, fields)

	stairsplus.recipeitems_list[recipeitem] = modname .. ":" .. subname
end

function stairsplus:register_alias_all(modname_old, subname_old, modname_new, subname_new)
	self:register_stair_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_slab_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_slope_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_panel_alias(modname_old, subname_old, modname_new, subname_new)
	self:register_micro_alias(modname_old, subname_old, modname_new, subname_new)
end
function stairsplus:register_alias_force_all(modname_old, subname_old, modname_new, subname_new)
	self:register_stair_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_slab_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_slope_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_panel_alias_force(modname_old, subname_old, modname_new, subname_new)
	self:register_micro_alias_force(modname_old, subname_old, modname_new, subname_new)
end

-- stairsplus:register_trunk_noface("default", "tree_noface", "default:tree", 3)
function stairsplus:register_noface_trunk(modname, subname, original_node_name, tile_index)
	local def = minetest.registered_nodes[original_node_name]
	if not def then
		minetest.log("error", "Cannot register noface trunk of unknown node "..original_node_name.."!")
		return false
	end
	def = table.copy(def)
	def.description = (def.description or "").." "..S("(no face)")
	local t = def.tiles[tile_index or 3] or def.tiles[#def.tiles] or def.tiles[1]
	if not t then
		minetest.log("error", "Cannot determine tiles for "..modname..":"..subname.."!")
		return false
	end
	def.tiles = {t}
	minetest.register_node(":"..modname..":"..subname, def)
	def = table.copy(def)
	def.sunlight_propagates = true
	stairsplus:register_all(modname, subname, modname..":"..subname, def)
end

function stairsplus:register_allfaces_trunk(modname, subname, original_node_name, tile_index)
	local def = minetest.registered_nodes[original_node_name]
	if not def then
		minetest.log("error", "Cannot register all-faces trunk of unknown node "..original_node_name.."!")
		return false
	end
	def = table.copy(def)
	def.description = (def.description or "").." "..S("(all faces)")
	local t = def.tiles[tile_index or 1] or def.tiles[#def.tiles]
	if not t then
		minetest.log("error", "Cannot determine tiles for "..modname..":"..subname.."!")
		return false
	end
	def.tiles = {t}
	minetest.register_node(":"..modname..":"..subname, def)
	def = table.copy(def)
	def.sunlight_propagates = true
	stairsplus:register_all(modname, subname, modname..":"..subname, def)
end

-- luacheck: no unused
local function register_stair_slab_panel_micro(modname, subname, recipeitem, groups, images, description, drop, light)
	stairsplus:register_all(modname, subname, recipeitem, {
		groups = groups,
		tiles = images,
		description = description,
		drop = drop,
		light_source = light
	})
end

local function on_mods_loaded()
	local i = 0
	for name, _ in pairs(stairsplus.recipeitems_list)
	do
		local node = minetest.registered_nodes[name]
		if node then
			local g = node.groups
			if g then
				g = table.copy(g)
				g.na_kp = 1
			else
				g = {na_kp = 1}
			end
			i = i + 1
		else
			minetest.log("error", "In recipeitems list there is " .. name .. " that is not a registered node!")
		end
	end
	minetest.log("info", "stairsplus: " .. i .. " nodes")
end

-- minetest.register_on_mods_loaded(on_mods_loaded)

dofile(modpath .. "/defs.lua")
dofile(modpath .. "/recipes.lua")
dofile(modpath .. "/common.lua")
dofile(modpath .. "/stairs.lua")
dofile(modpath .. "/slabs.lua")
dofile(modpath .. "/slopes.lua")
dofile(modpath .. "/panels.lua")
dofile(modpath .. "/microblocks.lua")
dofile(modpath .. "/custom.lua")
dofile(modpath .. "/registrations.lua")
