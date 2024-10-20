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

if minetest.get_modpath("ch_core") then
	ch_core.create_private_vgroup("na_kp", stairsplus.recipeitems_list)
end

if
	not minetest.get_modpath("unified_inventory")
	and minetest.settings:get_bool("creative_mode")
then
	stairsplus.expect_infinite_stacks = true
end

local groups_to_copy = {
	attached_node = true,
	bouncy = true,
	choppy = true,
	connect_to_raillike = true,
	cracky = true,
	crumbly = true,
	dig_immediate = true,
	disable_jump = true,
	disable_descend = true,
	explody = true,
	fall_damage_add_percent = true,
	falling_node = true,
	flammable = true,
	fleshy = true,
	float = true,
	level = true,
	oddly_breakable_by_hand = true,
	slippery = true,
	snappy = true,
}

function stairsplus:prepare_groups(groups)
	local result = {}
	if groups ~= nil then
		for k, v in pairs(groups) do
			if groups_to_copy[k] then
				result[k] = v
			end
		end
		--if not moreblocks.config.stairsplus_in_creative_inventory then
			--result.not_in_creative_inventory = 1
		--end
	end
	return result
end

local slabs_and_slopes_subset = {
	{ "micro", "" },
	{ "slab",  "" },
	{ "slab",  "_quarter" },
	{ "slab",  "_three_quarter" },
	{ "slab",  "_1" },
	{ "slab",  "_2" },
	{ "slab",  "_14" },
	{ "slab",  "_15" },
	{ "slope", "" },
	{ "slope", "_half" },
	{ "slope", "_half_raised" },
	{ "slope", "_inner" },
	{ "slope", "_inner_half" },
	{ "slope", "_inner_half_raised" },
	{ "slope", "_inner_cut" },
	{ "slope", "_inner_cut_half" },
	{ "slope", "_inner_cut_half_raised" },
	{ "slope", "_outer" },
	{ "slope", "_outer_half" },
	{ "slope", "_outer_half_raised" },
	{ "slope", "_outer_cut" },
	{ "slope", "_outer_cut_half" },
	-- { "slope", "_outer_cut_half_raised" },
	{ "slope", "_cut" },
	{ "slope", "_slab" },
	{ "slope", "_tripleslope" },
}

local function preprocess_tiles(tiles)
	local result
	if type(tiles) == "string" then
		result = {{name = tiles, backface_culling = true}}
	elseif type(tiles) == "table" then
		result = {}
		for i, tile in ipairs(tiles) do
			if type(tile) == "table" then
				result[i] = table.copy(tile)
				result[i].tileable_vertical = nil
				result[i].backface_culling = true
			else
				result[i] = {name = tile, backface_culling = true}
			end
		end
	else
		error("Invalid tiles format! "..dump2(tiles))
	end
	return result
end

function stairsplus:register_all(modname, subname, recipeitem, fields)
	local subset = ch_core.get_stairsplus_custom_shapes(recipeitem)
	if subset ~= nil then
		stairsplus:register_custom_subset(subset, modname, subname, recipeitem, fields)
		stairsplus:register_bank_slopes_internal(recipeitem, modname, subname)
	end
--[[
	fields.tiles = preprocess_tiles(fields.tiles)

	self:register_stair(modname, subname, recipeitem, fields)
	self:register_slab(modname, subname, recipeitem, fields)
	self:register_slope(modname, subname, recipeitem, fields)
	self:register_panel(modname, subname, recipeitem, fields)
	self:register_micro(modname, subname, recipeitem, fields)

	stairsplus.recipeitems_list[recipeitem] = modname .. ":" .. subname
	]]
end

--[[
function stairsplus:register_slabs_and_slopes(modname, subname, recipeitem, fields)
	fields.tiles = preprocess_tiles(fields.tiles)

	return self:register_custom_subset(slabs_and_slopes_subset, modname, subname, recipeitem, fields)
end
]]

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

-- stairsplus:register_noface_trunk("default", "tree_noface", "default:tree", 3)
function stairsplus:register_noface_trunk(modname, subname, original_node_name, tile_index, options)
	local def = minetest.registered_nodes[original_node_name]
	if not def then
		minetest.log("error", "Cannot register noface trunk of unknown node "..original_node_name.."!")
		return false
	end
	if options == nil then
		options = {}
	end
	local stairsplus_level = options.stairsplus or "all"
	def = table.copy(def)
	def.description = (def.description or "")..": "..S("no face")
	local t = def.tiles[tile_index or 3] or def.tiles[#def.tiles] or def.tiles[1]
	if not t then
		minetest.log("error", "Cannot determine tiles for "..modname..":"..subname.."!")
		return false
	end
	def.tiles = {t}
	minetest.register_node(":"..modname..":"..subname, def)
	def = table.copy(def)
	def.sunlight_propagates = true
	if stairsplus_level == "all" then
		stairsplus:register_all(modname, subname, modname..":"..subname, def)
	elseif stairsplus_level == "slopes" then
		stairsplus:register_slabs_and_slopes(modname, subname, modname..":"..subname, def)
	end

	local recipe_row = {original_node_name, original_node_name, original_node_name}
	local recipe_row2 = {original_node_name, "", original_node_name}
	minetest.register_craft({
		output = modname..":"..subname.." 8",
		recipe = {recipe_row, recipe_row2, recipe_row},
	})
end

function stairsplus:register_allfaces_trunk(modname, subname, original_node_name, tile_index, options)
	local def = minetest.registered_nodes[original_node_name]
	if not def then
		minetest.log("error", "Cannot register all-faces trunk of unknown node "..original_node_name.."!")
		return false
	end
	if options == nil then
		options = {}
	end
	local stairsplus_level = options.stairsplus or "none"
	def = table.copy(def)
	def.description = (def.description or "")..": "..S("all faces")
	local t = def.tiles[tile_index or 1] or def.tiles[#def.tiles]
	if not t then
		minetest.log("error", "Cannot determine tiles for "..modname..":"..subname.."!")
		return false
	end
	def.tiles = {t}
	minetest.register_node(":"..modname..":"..subname, def)
	def = table.copy(def)
	def.sunlight_propagates = true
	if stairsplus_level == "all" or stairsplus_level == "slopes" then
		stairsplus:register_all(modname, subname, modname..":"..subname, def)
	--[[ elseif stairsplus_level == "slopes" then
		stairsplus:register_slabs_and_slopes(modname, subname, modname..":"..subname, def) ]]
	end

	local recipe_row = {original_node_name, original_node_name, original_node_name}
	minetest.register_craft({
		output = modname..":"..subname.." 9",
		recipe = {recipe_row, recipe_row, recipe_row},
	})
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

ch_core.init_stairsplus_custom_shapes(stairsplus.defs)

dofile(modpath .. "/recipes.lua")
dofile(modpath .. "/common.lua")
dofile(modpath .. "/stairs.lua")
dofile(modpath .. "/slabs.lua")
dofile(modpath .. "/slopes.lua")
dofile(modpath .. "/panels.lua")
dofile(modpath .. "/microblocks.lua")
dofile(modpath .. "/custom.lua")
dofile(modpath .. "/bank_slopes.lua")
dofile(modpath .. "/registrations.lua")
dofile(modpath .. "/new_api.lua")
