--[[
More Blocks: bank slope definitions

Copyright © 2022,2024 Singularis and contributors
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local S = minetest.get_translator("moreblocks")

local defs = {
	[""] = {
		description = "pobřežní svah",
		mesh = "moreblocks_bank_slope.obj",
	},
	["_cut"] = {
		mesh = "moreblocks_bank_slope_cut.obj",
	},
	["_half"] = {
		mesh = "moreblocks_bank_slope_half.obj",
	},
	["_half_raised"] = {
		mesh = "moreblocks_bank_slope_half_raised.obj",
	},
	["_inner"] = {
		mesh = "moreblocks_bank_slope_inner.obj",
	},
	["_inner_cut"] = {
		mesh = "moreblocks_bank_slope_inner_cut.obj",
	},
	["_inner_cut_half"] = {
		mesh = "moreblocks_bank_slope_inner_cut_half.obj",
	},
	["_inner_cut_half_raised"] = {
		mesh = "moreblocks_bank_slope_inner_cut_half_raised.obj",
	},
	["_inner_half"] = {
		mesh = "moreblocks_bank_slope_inner_half.obj",
	},
	["_inner_half_raised"] = {
		mesh = "moreblocks_bank_slope_inner_half_raised.obj",
	},
	["_outer"] = {
		mesh = "moreblocks_bank_slope_outer.obj",
	},
	["_outer_half"] = {
		mesh = "moreblocks_bank_slope_outer_half.obj",
	},
	["_outer_half_raised"] = {
		mesh = "moreblocks_bank_slope_outer_half_raised.obj",
	},
}

local function process_box(box)
	if not box or box.type ~= "fixed" then
		error("process_box() not implemented for non-fixed boxes! Dump: "..dump2({box}))
	end
	local result = table.copy(box.fixed)
	for i, subbox in ipairs(box.fixed) do
		local shift_2 = subbox[2] > -0.4999
		local shift_5 = subbox[5] > -0.4999
		if shift_2 or shift_5 then
			local shifted_subbox = table.copy(subbox)
			if shift_2 then
				shifted_subbox[2] = subbox[2] + 1
			end
			if shift_5 then
				shifted_subbox[5] = subbox[5] + 1
			end
			result[i] = shifted_subbox
		end
	end
	return { type = "fixed", fixed = result }
end


function stairsplus:register_bank_slopes_internal(recipeitem, modname, subname)
	local recipeitem_def = minetest.registered_nodes[recipeitem]
	if not recipeitem_def then
		error("stairsplus:register_bank_slopes() called on unknown node "..recipeitem)
	end

	for alternate, slopedef in pairs(defs) do
		local original_slope = modname..":slope_"..subname..alternate
		local orig_slope_def = minetest.registered_nodes[original_slope]
		if ch_core.is_shape_allowed(recipeitem, "bank_slope", alternate) and orig_slope_def then
			local new_def = table.copy(orig_slope_def)
			new_def.name = nil
			new_def.mod_origin = nil
			new_def.drop = nil
			new_def._stairsplus_category = "bank_slope"
			new_def.description = (new_def.description or "neznámý blok")..": pobřežní svah"
			new_def.mesh = slopedef.mesh
			local same_box = new_def.collision_box == new_def.selection_box
			if new_def.collision_box then
				new_def.collision_box = process_box(new_def.collision_box)
			end
			if new_def.selection_box then
				if same_box then
					new_def.selection_box = new_def.collision_box
				else
					new_def.selection_box = process_box(new_def.selection_box)
				end
			end
			new_def.paramtype = "none"
			new_def.paramtype2 = "facedir"
			new_def._transparency = 0 -- for mod shadows

			local groups = new_def.groups or {}
			groups.not_in_creative_inventory = nil
			groups.slope = (groups.slope or 0) + 100
			new_def.groups = groups

			minetest.register_node(":"..modname..":bank_slope_"..subname..alternate, new_def)
			minetest.register_craft({
				output = modname..":bank_slope_"..subname..alternate,
				recipe = {
					{modname..":slope_"..subname..alternate, ""},
					{recipeitem, ""},
				},
			})
			minetest.register_craft({
				output = modname..":slope_"..subname..alternate,
				recipe = {{modname..":bank_slope_"..subname..alternate}},
				replacements = {
					{modname..":bank_slope_"..subname..alternate, recipeitem},
				},
			})
		end
	end
end
