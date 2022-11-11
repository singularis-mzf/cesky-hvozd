--[[
More Blocks: registrations

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local S = moreblocks.S

local descriptions = {
	["micro"] = "Microblock",
	["slab"] = "Slab",
	["slope"] = "Slope",
	["panel"] = "Panel",
	["stair"] = "Stairs",
}

-- Extends the standad rotate_node placement so that it takes into account
-- the side (top/bottom or left/right) of the face being pointed at.
-- As with the standard rotate_node, sneak can be used to force the perpendicular
-- placement (wall placement on floor/ceiling, floor/ceiling placement on walls).
-- Additionally, the aux / sprint / special key can be used to place the node
-- as if from the opposite side.
--
-- When placing a node next to one of the same category (e.g. slab to slab or
-- stair to stair), the default placement (regardless of sneak) is to copy the
-- under node's param2, flipping if placed above or below it. The aux key disable
-- this behavior.
local wall_right_dirmap = {9, 18, 7, 12}
local wall_left_dirmap = {11, 16, 5, 14}
local ceil_dirmap = {20, 23, 22, 21}

-- extract the stairsplus category from a node name
-- assumes the name is in the form mod_name:category_original_ndoe_name
local function name_to_category(name)
	local colon = name:find(":") or 0
	colon = colon + 1
	local under = name:find("_", colon)
	return name:sub(colon, under)
end

stairsplus.rotate_node_aux = function(itemstack, placer, pointed_thing)
	local sneak = placer and placer:get_player_control().sneak
	local aux = placer and placer:get_player_control().aux1

	-- category for what we are placing
	local item_prefix = name_to_category(itemstack:get_name())
	-- category for what we are placing against
	local under = pointed_thing.under
	local under_node = minetest.get_node(under)
	local under_prefix = under_node and name_to_category(under_node.name)

	local same_cat = item_prefix == under_prefix

	-- standard (floor) facedir, also used for sneak placement against the lower half of the wall
	local p2 = placer and minetest.dir_to_facedir(placer:get_look_dir()) or 0

	-- check which face and which quadrant we are interested in
	-- this is used both to check if we're handling parallel placement in the same-category case,
	-- and in general for sneak placement
	local face_pos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
	local face_off = vector.subtract(face_pos, under)

	-- we cannot trust face_off to tell us the correct directionif the
	-- under node has a non-standard shape, so use the distance between under and above
	local wallmounted = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.above, under))

	if same_cat and not aux then
		p2 = under_node.param2
		-- flip if placing above or below an upright or upside-down node
		-- TODO should we also flip when placing next to a side-mounted node?
		if wallmounted < 2 then
			if p2 < 4 then
				p2 = (p2 + 2) % 4
				p2 = ceil_dirmap[p2 + 1]
			elseif p2 > 19 then
				p2 = ceil_dirmap[p2 - 19] - 20
				p2 = (p2 + 2) % 4
			end
		end
	else
		-- for same-cat placement, aux is used to disable param2 copying
		if same_cat then
			aux = not aux
		end

		local remap = nil

		-- standard placement against the wall
		local use_wallmap = (wallmounted > 1 and not sneak) or (wallmounted < 2 and sneak)

		-- standard placement against the ceiling, or sneak placement against the upper half of the wall
		local use_ceilmap = wallmounted == 1 and not sneak
		use_ceilmap = use_ceilmap or (wallmounted > 1 and sneak and face_off.y > 0)

		if use_wallmap then
			local left = (p2 == 0 and face_off.x < 0) or
				(p2 == 1 and face_off.z > 0) or
				(p2 == 2 and face_off.x > 0) or
				(p2 == 3 and face_off.z < 0)
			if aux then
				left = not left
			end
			remap = left and wall_left_dirmap or wall_right_dirmap
		elseif use_ceilmap then
			remap = ceil_dirmap
		end

		if aux then
			p2 = (p2 + 2) % 4
		end

		if remap then
			p2 = remap[p2 + 1]
		end
	end

	return minetest.item_place(itemstack, placer, pointed_thing, p2)
end

local alternate_to_group_value = {
	[""] = 8,
	["_1"] = 1,
	["_2"] = 2,
	["_4"] = 4,
	["_12"] = 12,
	["_14"] = 14,
	["_15"] = 15,
	["_quarter"] = 4,
	["_three_quarter"] = 12,
	["_two_sides"] = 9,
	["_three_sides"] = 10,
	["_three_sides_u"] = 11,
	["_half"] = 8,
	["_half_raised"] = 12,
	["_inner"] = 1,
	["_inner_half"] = 2,
	["_inner_half_raised"] = 3,
	["_inner_cut"] = 7,
	["_inner_cut_half"] = 4,
	["_inner_cut_half_raised"] = 5,
	["_outer"] = 15,
	["_outer_half"] = 9,
	["_outer_half_raised"] = 10,
	["_outer_cut"] = 11,
	["_outer_cut_half"] = 12,
	["_outer_cut_half_raised"] = 13,
	["_cut"] = 14,
	["_right_half"] = 9,
	["_alt"] = 9,
	["_alt_1"] = 10,
	["_alt_2"] = 11,
	["_alt_4"] = 12,
}

stairsplus.register_single = function(category, alternate, info, modname, subname, recipeitem, fields)

	local src_def = minetest.registered_nodes[recipeitem] or {}
	local desc_base = fields.description
	local readable_alternate = alternate:gsub("_", " "):gsub("^%s*(.-)%s*$", "%1");
	local def = {}

	if readable_alternate == "" then
		readable_alternate = "normal";
	end

	if category ~= "slab" then
		def = table.copy(info)
	end

	-- copy fields to def
	for k, v in pairs(fields) do
		def[k] = v
	end

	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = def.paramtype2 or "facedir"
	if def.use_texture_alpha == nil then
		def.use_texture_alpha = src_def.use_texture_alpha
	end

	-- This makes node rotation work on placement
	def.place_param2 = nil

	-- Darken light sources slightly to make up for their smaller visual size
	def.light_source = math.max(0, (def.light_source or 0) - 1)

	def.on_place = stairsplus.rotate_node_aux
	def.groups = stairsplus:prepare_groups(fields.groups)
	def.groups[category] = alternate_to_group_value[alternate] or 1

	if category == "slab" then
		if type(info) ~= "table" then
			def.node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, (info/16)-0.5, 0.5},
			}
			def.description = ("%s (%s, %d/16)"):format(desc_base, S("Slab"), info)
		else
			def.node_box = {
				type = "fixed",
				fixed = info,
			}
			def.description = desc_base .. " (" .. S(descriptions[category]) .. ", " .. S(readable_alternate) .. ")"
		end
		if alternate == "_triplet" then
			def.groups.not_in_creative_inventory = nil
		end
	else
		def.description = ("%s (%s, %s)"):format(desc_base, S(descriptions[category]), S(readable_alternate))
		if category == "slope" then
			def.drawtype = "mesh"
		elseif category == "stair" and alternate == "" then
			def.groups.stair = 1
		end
	end

	--[[ if fields.drop and not (type(fields.drop) == "table") then
	if fields.drop then
		def.drop = modname.. ":" .. category .. "_" .. fields.drop .. alternate
	end ]]
	def.drop = nil
	def._stairsplus_recipeitem = recipeitem
	def._stairsplus_category = category
	def._stairsplus_alternate = alternate

	minetest.register_node(":" ..modname.. ":" .. category .. "_" .. subname .. alternate, def)
	stairsplus.register_recipes(category, alternate, modname, subname, recipeitem)
end
