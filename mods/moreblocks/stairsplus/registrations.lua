--[[
More Blocks: registrations

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]
local S = moreblocks.S
-- default registrations
if minetest.get_modpath("default") then
	local default_nodes = { -- Default stairs/slabs/panels/microblocks:
		"acacia_wood",
		"aspen_wood",
		"brick",
		"bronzeblock",
		"cobble",
		"copperblock",
		"coral_skeleton",
		"desert_cobble",
		"desert_sand",
		"desert_sandstone",
		"desert_sandstone_block",
		"desert_sandstone_brick",
		"desert_stone",
		"desert_stone_block",
		"desert_stonebrick",
		"diamondblock",
		"dirt",
		"glass",
		"goldblock",
		"gravel",
		"ice",
		"junglewood",
		"meselamp",
		-- "mossycobble",
		"obsidian",
		"obsidian_block",
		"obsidian_glass",
		"obsidianbrick",
		"pine_wood",
		"sand",
		"sandstone",
		"sandstone_block",
		"sandstonebrick",
		"silver_sand",
		"silver_sandstone",
		"silver_sandstone_block",
		"silver_sandstone_brick",
		"snowblock",
		"steelblock",
		"stone",
		"stone_block",
		"stonebrick",
		-- "tinblock",
		"wood",
	}
	local default_nodes_limited = {
		["desert_sand"] = true,
		["dirt"] = true,
		["gravel"] = true,
		["sand"] = true,
		["silver_sand"] = true,
		["snowblock"] = true,
	}

	for _, name in pairs(default_nodes) do
		local mod = "default"
		local nodename = mod .. ":" .. name
		local ndef = table.copy(minetest.registered_nodes[nodename])
		ndef.sunlight_propagates = true

		-- Stone and desert_stone drop cobble and desert_cobble respectively.
		if type(ndef.drop) == "string" then
			ndef.drop = ndef.drop:gsub(".+:", "")
		end

		-- Use the primary tile for all sides of cut glasslike nodes and disregard paramtype2.
		if #ndef.tiles > 1 and ndef.drawtype and ndef.drawtype:find("glass") then
			ndef.tiles = {ndef.tiles[1]}
			ndef.paramtype2 = nil
		end

		mod = "moreblocks"
		if default_nodes_limited[name] then
			stairsplus:register_slabs_and_slopes(mod, name, nodename, ndef)
		else
			stairsplus:register_all(mod, name, nodename, ndef)
			minetest.register_alias_force("stairs:stair_" .. name, mod .. ":stair_" .. name)
			minetest.register_alias_force("stairs:stair_outer_" .. name, mod .. ":stair_" .. name .. "_outer")
			minetest.register_alias_force("stairs:stair_inner_" .. name, mod .. ":stair_" .. name .. "_inner")
			minetest.register_alias_force("stairs:slab_"  .. name, mod .. ":slab_"  .. name)
		end
	end

	local default_trunks = {
		acacia_tree = {},
		aspen_tree = {},
		jungletree = {allfaces = {stairsplus = "slopes"}},
		pine_tree = {},
		tree = {allfaces = {stairsplus = "all"}},
	}
	for name, options in pairs(default_trunks) do
		stairsplus:register_noface_trunk("moreblocks", name .. "_noface", "default:"..name, nil, options.noface)
		stairsplus:register_allfaces_trunk("moreblocks", name .. "_allfaces", "default:"..name, nil, options.allfaces)
	end
end

-- farming registrations
if minetest.get_modpath("farming") then
	local farming_nodes = {"hemp_block", "straw"}
	for _, name in pairs(farming_nodes) do
		local mod = "farming"
		local nodename = mod .. ":" .. name
		if minetest.registered_nodes[nodename] then
			local ndef = table.copy(minetest.registered_nodes[nodename])
			ndef.sunlight_propagates = true

			mod = "moreblocks"
			stairsplus:register_slabs_and_slopes(mod, name, nodename, ndef)
			minetest.register_alias_force("stairs:stair_" .. name, mod .. ":stair_" .. name)
			minetest.register_alias_force("stairs:stair_outer_" .. name, mod .. ":stair_" .. name .. "_outer")
			minetest.register_alias_force("stairs:stair_inner_" .. name, mod .. ":stair_" .. name .. "_inner")
			minetest.register_alias_force("stairs:slab_"  .. name, mod .. ":slab_"  .. name)
		end
	end
end

-- wool registrations
local wool_shapes = {
	{ "micro", "" },
	{ "panel", "" },
	{ "panel", "_4" },
	{ "panel", "_special" },
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
	{ "slope", "_outer_cut_half_raised" },
	{ "slope", "_cut" },
	{ "slope", "_slab" },
	{ "slope", "_tripleslope" },
}

if minetest.get_modpath("wool") then
	local dyes = {"white", "grey", "black", "red", "yellow", "green", "cyan",
	              "blue", "magenta", "orange", "violet", "brown", "pink",
	              "dark_grey", "dark_green"}
	for _, name in pairs(dyes) do
		local mod = "wool"
		local nodename = mod .. ":" .. name
		local ndef = table.copy(minetest.registered_nodes[nodename])
		ndef.sunlight_propagates = true

		-- stairsplus:register_slabs_and_slopes(mod, name, nodename, ndef)
		stairsplus:register_custom_subset(wool_shapes, mod, name, nodename, ndef)
	end
end

-- basic_materials, keeping the original other-mod-oriented names
-- for backwards compatibility

if minetest.get_modpath("basic_materials") then
	stairsplus:register_all("technic","concrete","basic_materials:concrete_block",{
		description = minetest.registered_nodes["basic_materials:concrete_block"].description,
		tiles = {"basic_materials_concrete_block.png",},
		groups = {cracky=1, level=2, concrete=1},
		sounds = moreblocks.node_sound_stone_defaults(),
	})

	minetest.register_alias("prefab:concrete_stair","technic:stair_concrete")
	minetest.register_alias("prefab:concrete_slab","technic:slab_concrete")

	stairsplus:register_all("gloopblocks", "cement", "basic_materials:cement_block", {
		description = minetest.registered_nodes["basic_materials:cement_block"].description,
		tiles = {"basic_materials_cement_block.png"},
		groups = {cracky=2, not_in_creative_inventory=1},
		sounds = moreblocks.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("technic", "brass_block", "basic_materials:brass_block", {
		description = minetest.registered_nodes["basic_materials:brass_block"].description,
		groups={cracky=1, not_in_creative_inventory=1},
		tiles={"basic_materials_brass_block.png"},
		sounds = moreblocks.node_sound_metal_defaults(),
	})

end

-- Alias cuts of split_stone_tile_alt which was renamed checker_stone_tile.
stairsplus:register_alias_all("moreblocks", "split_stone_tile_alt", "moreblocks", "checker_stone_tile")

stairsplus:register_bank_slopes("default:dirt")
stairsplus:register_bank_slopes("default:gravel")
stairsplus:register_bank_slopes("default:sand")

-- The following LBM is necessary because the name stair_split_stone_tile_alt
-- conflicts with another node and so the alias for that specific node gets
-- ignored.
minetest.register_lbm({
	name = "moreblocks:fix_split_stone_tile_alt_name_collision",
	nodenames = {"moreblocks:stair_split_stone_tile_alt"},
	action = function(pos, node)
		minetest.set_node(pos, {
			name = "moreblocks:stair_checker_stone_tile",
			param2 = minetest.get_node(pos).param2

		})
		minetest.log('action', "LBM replaced " .. node.name ..
				" at " .. minetest.pos_to_string(pos))
	end,
})
